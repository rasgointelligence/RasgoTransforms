import unittest

import pytest

from rasgotransforms.render import RasgoEnvironment
from rasgotransforms.testing_utils import run_query, get_columns, get_source_code, save_artifacts


@pytest.mark.skip(reason='Requires a connection to the data warehouse')
class TestPlotTransform(unittest.TestCase):
    def test_datetime_no_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2021-02-01',
                'time_grain': 'day',
            },
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'columnName': 'UNITPRICE',
                    'operator': '>=',
                    'comparisonValue': 1,
                },
                {'columnName': 'COLOR', 'operator': '=', 'comparisonValue': "'Black'", 'compoundBoolean': 'OR'},
            ],
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('ORDERDATE_MIN', df.columns)

    def test_datetime_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            'group_by': ['COLOR'],
            'max_num_groups': 50,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'month',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('ORDERDATE_MIN', df.columns)

    def test_datetime_all_timegrain(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'ORDERDATE',
            'num_buckets': 200,
            # 'group_by': ['COLOR'],
            'max_num_groups': 50,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'all',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('ORDERDATE_MIN', df.columns)
        self.assertEqual(1, df.shape[0])

    def test_continuous_no_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'UNITPRICE',
            'num_buckets': 200,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2021-02-01',
                'time_grain': 'day',
            },
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'columnName': 'UNITPRICE',
                    'operator': '>=',
                    'comparisonValue': 1,
                }
            ],
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('UNITPRICE_MIN', df.columns)

    def test_continuous_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'UNITPRICE',
            'num_buckets': 200,
            'group_by': ['COLOR', 'SALESTERRITORYKEY'],
            'max_num_groups': 50,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'timeseries_options': {
                'start_date': '2021-01-01',
                'end_date': '2022-02-01',
                'time_grain': 'month',
            },
            'metrics': {'SALESAMOUNT': ['SUM'], 'SALESORDERNUMBER': ['COUNT DISTINCT']},
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('UNITPRICE_MAX', df.columns)

    def test_categorical_no_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'COLOR',
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'metrics': {'SALESAMOUNT': ['SUM', 'AVG']},
            'filters': [
                {
                    'columnName': 'UNITPRICE',
                    'operator': '>=',
                    'comparisonValue': 1,
                }
            ],
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('COLOR', df.columns)

    def test_categorical_dimensions(self):
        source_code = get_source_code('plot')
        args = {
            'x_axis': 'COLOR',
            'group_by': ['SALESTERRITORYKEY'],
            'max_num_groups': 2,
            'source_table': 'RASGO.PUBLIC.KH_TEST_TABLE',
            'metrics': {'SALESAMOUNT': ['SUM']},
        }
        environment = RasgoEnvironment(dw_type="snowflake", run_query=run_query)
        rendered = environment.render(
            source_code=source_code,
            arguments=args,
            source_table='RASGO.PUBLIC.KH_TEST_TABLE',
            override_globals={'get_columns': get_columns},
        )
        assert rendered

        df = run_query(rendered)
        save_artifacts(args=args, sql=rendered, output=df)
        self.assertIn('COLOR', df.columns)
        self.assertIn('_OTHERGROUP_SALESAMOUNT_SUM', df.columns)


if __name__ == '__main__':
    unittest.main()
