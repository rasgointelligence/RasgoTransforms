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
            "is_date_string": is_date_string,
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


def get_timedelta(time_grain: str, interval: int = None) -> timedelta:
    time_grain = time_grain.lower()
    current_time = datetime.utcnow()
    if time_grain == 'hour':
        if not interval:
            return current_time - current_time.replace(minute=0, second=0, microsecond=0)
        return timedelta(hours=interval)
    elif time_grain == 'day':
        if not interval:
            return current_time - current_time.replace(minute=0, second=0, microsecond=0)
        return timedelta(days=interval)
    elif time_grain == 'week':
        if not interval:
            return timedelta(
                days=current_time.isoweekday(),
                hours=current_time.hour,
                minutes=current_time.minute,
                seconds=current_time.second,
                microseconds=current_time.microsecond,
            )
        return timedelta(weeks=interval)
    elif time_grain == 'month':
        if not interval:
            return current_time - current_time.replace(day=1, minute=0, second=0, microsecond=0)
        interval *= 31
        return timedelta(days=interval)
    elif time_grain == 'quarter':
        if not interval:
            return current_time - current_time.replace(
                month=((current_time.month - 1) // 3) * 3 + 1, day=1, minute=0, second=0, microsecond=0
            )
        interval *= 92
        return timedelta(days=interval)
    elif time_grain == 'year':
        if not interval:
            return current_time - current_time.replace(month=1, day=1, minute=0, second=0, microsecond=0)
        interval *= 365
        return timedelta(days=interval)
    else:
        raise RenderException(f"Invalid time grain '{time_grain}'")


def time_from_start_of_period(time_grain: str) -> timedelta:
    """
    Helper method that returns (current time - start of period/time grain)
    """
    time_grain = time_grain.lower()
    current_time = datetime.utcnow()
    if time_grain == 'hour':
        return current_time - current_time.replace(minute=0, second=0, microsecond=0)
    elif time_grain == 'day':
        return current_time - current_time.replace(minute=0, second=0, microsecond=0)
    elif time_grain == 'week':
        return timedelta(
            days=current_time.isoweekday(),
            hours=current_time.hour,
            minutes=current_time.minute,
            seconds=current_time.second,
            microseconds=current_time.microsecond,
        )
    elif time_grain == 'month':
        return current_time - current_time.replace(day=1, minute=0, second=0, microsecond=0)
    elif time_grain == 'quarter':
        return current_time - current_time.replace(
            month=((current_time.month - 1) // 3) * 3 + 1, day=1, minute=0, second=0, microsecond=0
        )
    elif time_grain == 'year':
        return current_time - current_time.replace(month=1, day=1, minute=0, second=0, microsecond=0)
    else:
        raise RenderException(f"Invalid time grain '{time_grain}'")


def parse_comparison_value(comparison_value, dw_type: DataWarehouse):
    if not isinstance(comparison_value, dict):
        return quote(comparison_value)
    direction = comparison_value.get('direction', 'none').lower()
    offset = comparison_value.get('offset', 0) or 0
    if direction == 'past':
        comparison_value['offset'] = -abs(offset)
    else:
        comparison_value['offset'] = abs(offset)
    date_part = comparison_value.get('date_part', comparison_value.get('datePart'))
    if comparison_value['type'].lower() == 'relative_date':
        if dw_type == DataWarehouse.SNOWFLAKE:
            return f"DATEADD({date_part}, {comparison_value['offset']}, CURRENT_DATE)"
        elif dw_type == DataWarehouse.BIGQUERY:
            return f"DATE_ADD(CURRENT_DATE, INTERVAL {comparison_value['offset']} {date_part})"
        else:
            return f"(CURRENT_DATE + INTERVAL {comparison_value['offset']} {date_part})"
    elif comparison_value['type'].lower() == 'start_of_period':
        if dw_type == DataWarehouse.SNOWFLAKE:
            return f"DATE_TRUNC({date_part}, CURRENT_DATE)"
        elif dw_type == DataWarehouse.BIGQUERY:
            return f"DATE_TRUNC(CURRENT_DATE, {date_part})"
        else:
            return f"DATE_TRUNC({date_part}, CURRENT_DATE)"
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


def is_date_string(value: str) -> bool:
    """
    Test to determine if string is a date string
    """
    try:
        datetime.fromisoformat(value)
        return True
    except ValueError:
        return False


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
        direction = start_date.get('direction', 'none').lower()
        offset = start_date.get('offset', 0)
        if direction == 'past':
            start_date['offset'] = -abs(offset)
        else:
            start_date['offset'] = abs(offset)
        date_part = start_date.get('date_part', start_date.get('datePart', None))
        if start_date['type'].lower() == 'start_of_period':
            time_delta = time_from_start_of_period(date_part)
        else:
            time_delta = get_timedelta(date_part, start_date['offset']) - max_timedelta
        return parse_comparison_value(
            {
                'type': 'relative_date',
                'offset': time_delta.days,
                'date_part': 'DAY',
                'direction': 'past' if time_delta.days < 0 else 'future',
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
