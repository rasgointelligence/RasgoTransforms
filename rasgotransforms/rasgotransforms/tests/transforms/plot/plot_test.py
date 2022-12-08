from functools import partial

import pytest
import logging

from rasgotransforms.render import RasgoEnvironment
from rasgotransforms.tests.utils_test import run_query, get_columns, get_source_code, save_artifacts

LOGGER = logging.getLogger(__name__)
SNOWFLAKE_TEST_TABLE = 'RASGO.PUBLIC.KH_TEST_TABLE'
BIGQUERY_TEST_TABLE = 'rasgodb.public.kh_test_view'


@pytest.mark.skip(reason='Requires a connection to the data warehouse')
@pytest.mark.parametrize("dw_type", ["snowflake", "bigquery"])
class TestPlotTransform:
    def test_datetime_no_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            'source_table': source_table,
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2021-02-01',
                'time_grain': 'day',
            },
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'column_name': 'UNITPRICE',
                    'operator': '>=',
                    'comparison_value': 1,
                },
                {
                    'column_name': 'COLOR', 
                    'operator': '=', 
                    'comparison_value': "'Black'", 
                    'compoundBoolean': 'OR'
                },
            ],
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(args=args, sql=rendered, output=df, dw_type=dw_type)
        assert 'ORDERDATE_MIN' in [c.upper() for c in df.columns]

    def test_datetime_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            'group_by': ['COLOR', 'CLASS'],
            'max_num_groups': 50,
            'source_table': source_table,
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'month',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(args=args, sql=rendered, output=df, dw_type=dw_type)
        assert 'ORDERDATE_MIN' in [c.upper() for c in df.columns]

    def test_datetime_all_timegrain(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            # 'group_by': ['COLOR'],
            'max_num_groups': 50,
            'source_table': source_table,
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'all',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        assert 'ORDERDATE_MIN' in [c.upper() for c in df.columns]
        assert 1 == df.shape[0]

    def test_continuous_no_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'UNITPRICE',
            'num_buckets': 200,
            'source_table': source_table,
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2021-02-01',
                'time_grain': 'day',
            },
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'column_name': 'UNITPRICE',
                    'operator': '>=',
                    'comparison_value': 1,
                }
            ],
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(args=args, sql=rendered, output=df, dw_type=dw_type)
        assert 'UNITPRICE_MIN' in [c.upper() for c in df.columns]

    def test_continuous_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'UNITPRICE',
            'num_buckets': 200,
            'group_by': ['COLOR', 'SALESTERRITORYKEY'],
            'max_num_groups': 10,
            'source_table': source_table,
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'month',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(args=args, sql=rendered, output=df, dw_type=dw_type)
        assert 'UNITPRICE_MAX' in [c.upper() for c in df.columns]

    def test_categorical_no_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'COLOR',
            'source_table': source_table,
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'column_name': 'UNITPRICE',
                    'operator': '>=',
                    'comparison_value': 1,
                }
            ],
        }
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(args=args, sql=rendered, output=df, dw_type=dw_type)
        assert 'COLOR' in [c.upper() for c in df.columns]

    def test_categorical_dimensions(self, dw_type):
        source_code = get_source_code('plot')
        source_table = BIGQUERY_TEST_TABLE if dw_type == 'bigquery' else SNOWFLAKE_TEST_TABLE
        args = {
            'x_axis': 'COLOR',
            'group_by': ['SALESTERRITORYKEY'],
            'max_num_groups': 2,
            'source_table': source_table,
            'metrics': {'SALESAMOUNT': ['SUM']},
        }
        save_artifacts(args=args, dw_type=dw_type)
        environment = RasgoEnvironment(dw_type=dw_type, run_query=partial(run_query, dw_type=dw_type))
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table=source_table,
            override_globals={'get_columns': partial(get_columns, dw_type=dw_type)},
        )
        assert rendered
        save_artifacts(sql=rendered, dw_type=dw_type)

        df = run_query(rendered, dw_type=dw_type)
        save_artifacts(output=df, dw_type=dw_type)
        assert 'COLOR' in [c.upper() for c in df.columns]
        if dw_type == 'bigquery':
            assert 'SALESAMOUNT_SUM__OTHERGROUP' in [c.upper() for c in df.columns]
        else:
            assert '_OTHERGROUP_SALESAMOUNT_SUM' in [c.upper() for c in df.columns]
