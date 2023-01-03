import re
from datetime import datetime, timedelta
from itertools import combinations, permutations, product
from typing import Callable, Optional, Dict, Union
from pathlib import Path
from os.path import getmtime
from functools import partial

from jinja2 import Environment, BaseLoader
from jinja2.exceptions import TemplateNotFound
import json

from rasgotransforms.exceptions import RenderException
from rasgotransforms.main import DataWarehouse


class RasgoEnvironment(Environment):
    def __init__(self, run_query: Optional[Callable] = None, dw_type: Optional[str] = None, *args, **kwargs):
        super().__init__(*args, extensions=self.rasgo_extensions, loader=RasgoLoader(), **kwargs)
        if not dw_type:
            dw_type = 'snowflake'
        self._dw_type = DataWarehouse(dw_type)
        for filter_name, method in self.rasgo_filters.items():
            self.filters[filter_name] = method
        for name, value in self.rasgo_globals.items():
            self.globals[name] = value
        self._run_query = run_query
        self.globals['run_query'] = self._run_query

    @property
    def dw_type(self) -> DataWarehouse:
        return self._dw_type

    @dw_type.setter
    def dw_type(self, dw_type: str):
        self._dw_type = DataWarehouse(dw_type)

    @property
    def rasgo_extensions(self):
        return ['jinja2.ext.do', 'jinja2.ext.loopcontrols']

    @property
    def rasgo_globals(self):
        return {
            "min": min,
            "max": max,
            "cleanse_name": cleanse_template_symbol,
            "raise_exception": raise_exception,
            "itertools": {"combinations": combinations, "permutations": permutations, "product": product},
            "dw_type": lambda: self.dw_type.value,
            "get_timedelta": get_timedelta,
            "parse_comparison_value": partial(parse_comparison_value, dw_type=self.dw_type),
            "quote": quote,
            "adjust_start_date": partial(adjust_start_date, dw_type=self.dw_type),
        }

    @property
    def rasgo_filters(self):
        return {
            "todatetime": datetime.fromisoformat,
            "to_json": json.dumps,
            "from_json": json.loads,
            "to_set": lambda x: set(x),
        }

    def render(
        self,
        source_code: str,
        arguments: dict,
        source_table: str = None,
        source_columns: Optional[Dict[str, Dict[str, str]]] = None,
        override_globals: Optional[Dict[str, Callable]] = None,
    ) -> str:
        """
        Given the source code of a jinja template, its arguments, and metadata about the source table,
        this renders the transform sql.

        Source columns can is a mapping of table names to columns (e.g. {table_name: {column_name: column_type}})
        """
        arguments['source_table'] = source_table

        if not override_globals:
            override_globals = {}

        if source_columns and 'get_columns' not in override_globals:

            def get_columns(fqtn):
                return source_columns[fqtn]

            override_globals['get_columns'] = get_columns
        if 'get_columns' in override_globals:
            self.globals['get_columns'] = override_globals['get_columns']
        try:
            template = self.from_string(source_code)
            rendered = template.render(**arguments, **override_globals)
        except Exception as e:
            raise RenderException(e)
        return trim_blank_lines(rendered)


def cleanse_template_symbol(symbol: str) -> str:
    symbol = str(symbol).strip().replace(' ', '_').replace('-', '_')
    symbol = re.sub('[^A-Za-z0-9_]+', '', symbol)
    symbol = '_' + symbol if not symbol or symbol[0].isdecimal() else symbol
    return symbol


def raise_exception(message: str) -> None:
    raise Exception(message)


def trim_blank_lines(sql: str) -> str:
    return re.sub(r'[\n][\s]*\n', '\n', sql)


def get_timedelta(time_grain: str, interval: int) -> timedelta:
    time_grain = time_grain.lower()
    if time_grain == 'hour':
        return timedelta(hours=interval)
    elif time_grain == 'day':
        return timedelta(days=interval)
    elif time_grain == 'week':
        return timedelta(weeks=interval)
    elif time_grain == 'month':
        interval *= 31
        return timedelta(days=interval)
    elif time_grain == 'quarter':
        interval *= 92
        return timedelta(days=interval)
    elif time_grain == 'year':
        interval *= 365
        return timedelta(days=interval)
    else:
        raise RenderException(f"Invalid time grain '{time_grain}'")


def parse_comparison_value(comparison_value, dw_type: DataWarehouse):
    if not isinstance(comparison_value, dict):
        return quote(comparison_value)
    if comparison_value['type'].lower() == 'relativedate':
        date_part = comparison_value.get('date_part', comparison_value.get('datePart'))
        if comparison_value['direction'].lower() == 'past':
            offset = -comparison_value['offset']
        else:
            offset = comparison_value['offset']
        if dw_type == DataWarehouse.SNOWFLAKE:
            return f"DATEADD({date_part}, {offset}, CURRENT_DATE)"
        elif dw_type == DataWarehouse.BIGQUERY:
            return f"DATE_ADD(CURRENT_DATE, INTERVAL {offset} {date_part})"
        else:
            return f"(CURRENT_DATE + INTERVAL {offset} {date_part})"
    else:
        raise RenderException(f"Invalid comparison value object type '{comparison_value['type']}'")


def quote(value):
    """
    Helper method used to add quotes around strings only if they don't already exist
    """
    if isinstance(value, str) and not value.startswith("'"):
        return f"'{value}'"
    else:
        return value


def adjust_start_date(start_date, time_grain, secondary_calculations, dw_type: DataWarehouse):
    if not secondary_calculations:
        return parse_comparison_value(start_date, dw_type=dw_type)
    max_timedelta = timedelta(0)
    for calc in secondary_calculations:
        if 'interval' in calc:
            max_timedelta = max(max_timedelta, get_timedelta(time_grain, calc['interval']))
        elif 'period' in calc:
            max_timedelta = max(max_timedelta, get_timedelta(calc['period'], 1))

    if isinstance(start_date, dict):
        date_part = start_date.get('date_part', start_date.get('datePart', None))
        if start_date['direction'].lower() == 'past':
            time_delta = -get_timedelta(date_part, start_date['offset']) - max_timedelta
        else:
            time_delta = get_timedelta(date_part, start_date['offset']) - max_timedelta
        return parse_comparison_value(
            {
                'type': 'relativedate',
                'direction': 'past' if time_delta < timedelta(0) else 'future',
                'offset': abs(time_delta.days),
                'date_part': 'DAY',
            },
            dw_type=dw_type,
        )

    if isinstance(start_date, str):
        start_date = datetime.fromisoformat(start_date)
    return quote((start_date - max_timedelta).date().isoformat())


class RasgoLoader(BaseLoader):
    def __init__(self, root_path=None):
        if not root_path:
            root_path = Path(__file__).parent.parent / 'macros'
        self.root_path = root_path

    def get_source(self, environment: RasgoEnvironment, template):
        template_path = self.root_path / environment.dw_type.value / template
        if not template_path.exists():
            template_path = self.root_path / template
            if not template_path.exists():
                raise TemplateNotFound(template)
        mtime = getmtime(template_path)
        return template_path.read_text(), template_path, lambda: mtime == getmtime(template_path)
