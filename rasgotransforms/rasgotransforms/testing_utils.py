from pathlib import Path
import os
import inspect
import json
from typing import List

import pandas as pd
from snowflake import connector as sf_connector
from dotenv import load_dotenv
from jinja2.nodes import Macro

from rasgotransforms.main import _load_all_yaml_files, _parse_transform_args_from_yaml, TransformTemplate
from rasgotransforms.render import RasgoEnvironment

DOTENV_PATH = Path(os.path.dirname(__file__)).parent.parent / ".env"
load_dotenv(DOTENV_PATH)

TRANSFORMS_DIR = Path(os.path.dirname(__file__)) / "transforms"
MACROS_DIR = Path(os.path.dirname(__file__)) / "macros"
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


def _get_templates(transform_name: str) -> dict:
    """
    Return all versions of a transform's source code mapped to the dw type
    """
    templates = {}
    for template in (TRANSFORMS_DIR / transform_name).glob('**/*.sql'):
        dw_type = template.parent.name
        if dw_type == transform_name:
            dw_type = 'generic'
        templates[dw_type] = template.read_text()
    return templates


def get_all_transform_templates() -> List[TransformTemplate]:
    """
    Return a list of all Rasgo Transform Templates
    """

    template_list = []
    transform_yamls = _load_all_yaml_files()
    for transform_name, transform_yaml in transform_yamls.items():
        transform_templates = _get_templates(transform_name=transform_name)
        transform_args = _parse_transform_args_from_yaml(transform_yaml)
        for dw_type, transform_source_code in transform_templates.items():
            template_list.append(
                TransformTemplate(
                    name=f"{transform_name}-{dw_type}",
                    source_code=transform_source_code,
                    arguments=transform_args,
                    description=transform_yaml.get('description'),
                    tags=transform_yaml.get('tags'),
                    dw_type=dw_type if dw_type != 'generic' else None,
                )
            )
    return template_list


def get_all_macros() -> dict:
    environment = RasgoEnvironment(dw_type='snowflake', run_query=None)
    all_macros = {}
    for macro_file in MACROS_DIR.glob('**/*.sql'):
        try:
            parsed = environment.parse(macro_file.read_text())
        except Exception as e:
            raise Exception(f"Error loading template file {macro_file}")
        macros = [node for node in parsed.body if type(node) is Macro]
        macro_names = [m.name for m in macros]
        if macro_file.name in all_macros.keys():
            assert set(macro_names) == set(all_macros[macro_file.name])
        else:
            all_macros[macro_file.name] = macro_names
    return all_macros
