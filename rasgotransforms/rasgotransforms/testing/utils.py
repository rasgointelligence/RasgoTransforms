import unittest
from pathlib import Path
import os
import inspect
import json

import pandas as pd
from snowflake import connector as sf_connector
from dotenv import load_dotenv

from rasgotransforms import serve_rasgo_transform_templates
from rasgotransforms.render import RasgoEnvironment
import sqlvalidator

DOTENV_PATH = Path(os.path.dirname(__file__)).parent.parent.parent / ".env"
load_dotenv(DOTENV_PATH)

TRANSFORMS_DIR = Path(os.path.dirname(__file__)).parent / "transforms"
SNOWFLAKE_ACCOUNT = os.environ.get('SNOWFLAKE_ACCOUNT')
SNOWFLAKE_WAREHOUSE = os.environ.get('SNOWFLAKE_WAREHOUSE')
SNOWFLAKE_USER = os.environ.get('SNOWFLAKE_USER')
SNOWFLAKE_PASSWORD = os.environ.get('SNOWFLAKE_PASSWORD')
SNOWFLAKE_ROLE = os.environ.get('SNOWFLAKE_ROLE')
ARTIFACTS_DIR = os.environ.get('ARTIFACTS_DIR')


CREDS = {
    "account": SNOWFLAKE_ACCOUNT,
    "warehouse": SNOWFLAKE_WAREHOUSE,
    "user": SNOWFLAKE_USER,
    "password": SNOWFLAKE_PASSWORD,
    "role": SNOWFLAKE_ROLE,
}


def query_into_dataframe(query) -> pd.DataFrame:
    cursor = sf_connector.connect(**CREDS).cursor()
    query_return = cursor.execute(query).fetch_pandas_all()
    cursor.close()
    return query_return


def run_query(query_str: str) -> pd.DataFrame:
    # print(f'Running query:\n{query_str}\n')
    return query_into_dataframe(f"SELECT * FROM ({query_str}) AS subq LIMIT 100")


def get_columns(source_table: str) -> dict:
    database, schema, table_name = source_table.split('.')
    query_string = f"""
    SELECT COLUMN_NAME, DATA_TYPE
    FROM {database}.information_schema.columns
    WHERE TABLE_CATALOG = '{database.upper()}'
        AND TABLE_SCHEMA = '{schema.upper()}'
        AND TABLE_NAME = '{table_name.upper()}'
    """
    df = run_query(query_string)
    columns = df.set_index('COLUMN_NAME')['DATA_TYPE'].to_dict()
    return columns


def get_source_code(transform_name):
    with open(TRANSFORMS_DIR / transform_name.lower() / f"{transform_name.lower()}.sql") as fp:
        return fp.read()


def save_artifacts(args: dict, sql: str, output: pd.DataFrame):
    if ARTIFACTS_DIR:
        test_name = inspect.stack()[1][3]
        artifact_subdir = Path(ARTIFACTS_DIR) / test_name
        if not artifact_subdir.exists():
            artifact_subdir.mkdir(parents=True)
        with open(artifact_subdir / "args.json", "w") as fp:
            json.dump(args, fp)
        with open(artifact_subdir / "query.sql", "w") as fp:
            fp.write(sql)
        output.to_csv(artifact_subdir / "output.csv", index=False)
