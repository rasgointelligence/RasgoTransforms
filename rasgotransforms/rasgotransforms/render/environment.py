import functools
import re
from datetime import datetime, timedelta
from itertools import combinations, permutations, product
from os.path import getmtime
from pathlib import Path
from typing import Callable, Dict, List, Optional, Union

from jinja2 import Environment, BaseLoader
from jinja2.exceptions import TemplateNotFound
import json

from rasgotransforms.exceptions import RenderException
from rasgotransforms.main import DataWarehouse

ALLOWED_OPERATORS = (
    ">",
    "<",
    "=",
    "<>",
    ">=",
    "<=",
    "CONTAINS",
    "IS NULL",
    "IS NOT NULL",
    "NOT CONTAINS",
    "IN",
    "NOT IN",
)


class RasgoEnvironment(Environment):
    def __init__(self, run_query: Optional[Callable] = None, dw_type: Optional[str] = None, *args, **kwargs):
        super().__init__(*args, extensions=self.rasgo_extensions, loader=RasgoLoader(), **kwargs)
        if not dw_type:
            dw_type = "snowflake"
        self._dw_type = DataWarehouse(dw_type)
        for filter_name, method in self.rasgo_filters.items():
            self.filters[filter_name] = method
        for name, value in self.rasgo_globals.items():
            self.globals[name] = value
        self._run_query = run_query
        self.globals["run_query"] = self._run_query

    @property
    def dw_type(self) -> DataWarehouse:
        return self._dw_type

    @dw_type.setter
    def dw_type(self, dw_type: str):
        self._dw_type = DataWarehouse(dw_type)

    @property
    def rasgo_extensions(self):
        return ["jinja2.ext.do", "jinja2.ext.loopcontrols"]

    @property
    def rasgo_globals(self):
        return {
            "min": min,
            "max": max,
            "cleanse_name": cleanse_template_symbol,
            "get_filter_statement": functools.partial(get_filter_statement, dw_type=self.dw_type),
            "combine_filters": functools.partial(combine_filters, dw_type=self.dw_type),
            "raise_exception": raise_exception,
            "itertools": {"combinations": combinations, "permutations": permutations, "product": product},
            "dw_type": lambda: self.dw_type.value,
            "get_timedelta": get_timedelta,
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
        arguments["source_table"] = source_table

        if not override_globals:
            override_globals = {}

        if source_columns and "get_columns" not in override_globals:

            def get_columns(fqtn):
                return source_columns[fqtn]

            override_globals["get_columns"] = get_columns
        if "get_columns" in override_globals:
            self.globals["get_columns"] = override_globals["get_columns"]
        try:
            template = self.from_string(source_code)
            rendered = template.render(**arguments, **override_globals)
        except Exception as e:
            raise RenderException(e) from e
        return trim_blank_lines(rendered)


def cleanse_template_symbol(symbol: str) -> str:
    symbol = str(symbol).strip().replace(" ", "_").replace("-", "_")
    symbol = re.sub("[^A-Za-z0-9_]+", "", symbol)
    symbol = "_" + symbol if not symbol or symbol[0].isdecimal() else symbol
    return symbol


def combine_filters(
    filters_a: Union[List, str],
    filters_b: Union[List, str],
    condition: str,
    dw_type: DataWarehouse,
) -> str:
    """
    Parse & combine multiple filters, return a single SQL statement
    """
    condition = condition or "AND"
    if filters_a and not filters_b:
        return get_filter_statement(filters_a, dw_type)
    elif filters_b and not filters_a:
        return get_filter_statement(filters_b, dw_type)
    elif not filters_a and not filters_b:
        return "TRUE"
    return f"({get_filter_statement(filters_a, dw_type)} {condition} {get_filter_statement(filters_b, dw_type)})"


def get_filter_statement(
    filters: Union[List, str],
    dw_type: DataWarehouse,
) -> str:
    """
    Parse a list of string or dict filters to a simple SQL string
    """
    if isinstance(filters, str):
        return filters

    filter_string = "TRUE"
    compound_boolean = "AND"
    for fil in filters:
        if isinstance(fil, dict):
            # Handle variable casing from past versions: only support snake eventually
            column_name = fil.get("column_name", fil.get("columnName"))
            operator = fil.get("operator", "").upper()
            comparison_value = fil.get("comparison_value", fil.get("comparisonValue"))
            compound_boolean = fil.get("compound_boolean", fil.get("compoundBoolean", compound_boolean))

            # Handle override operators
            if operator not in ALLOWED_OPERATORS:
                raise_exception(f"operator {operator} is not supported")
            if operator == "CONTAINS":
                operator = "LIKE"

            # Parse complex comparison values
            if isinstance(comparison_value, dict):
                # Relative Date filter
                if comparison_value.get("type", "").upper() == "RELATIVEDATE":
                    date_part = comparison_value.get("date_part", comparison_value.get("datePart"))
                    interval = f"{'-' if comparison_value['direction'] == 'past' else ''}{comparison_value['offset']}"
                    if not (date_part and interval):
                        raise_exception("relativedate comparisons must pass arguments: date_part, offset, direction")
                    print(dw_type)
                    if dw_type is DataWarehouse.BIGQUERY:
                        comparison_value = f"DATE_ADD(CURRENT_DATE(), INTERVAL {interval} {date_part})"
                    elif dw_type is DataWarehouse.SNOWFLAKE:
                        comparison_value = f"DATEADD({date_part}, {interval}, CURRENT_DATE)"
                    else:
                        comparison_value = f"(CURRENT_DATE + INTERVAL '{interval} {date_part}')"
            filter_string += f" {compound_boolean} {column_name} {operator} {comparison_value} \n"
        elif isinstance(fil, str) and fil != "":
            filter_string += f" {compound_boolean} {fil} \n"
    return filter_string


def raise_exception(message: str) -> None:
    raise Exception(message)


def trim_blank_lines(sql: str) -> str:
    return re.sub(r"[\n][\s]*\n", "\n", sql)


def get_timedelta(time_grain: str, interval: int) -> timedelta:
    time_grain = time_grain.lower()
    if time_grain == "hour":
        return timedelta(hours=interval)
    elif time_grain == "day":
        return timedelta(days=interval)
    elif time_grain == "week":
        return timedelta(weeks=interval)
    elif time_grain == "month":
        interval *= 31
        return timedelta(days=interval)
    elif time_grain == "quarter":
        interval *= 122
        return timedelta(days=interval)
    elif time_grain == "year":
        interval *= 365
        return timedelta(days=interval)
    else:
        raise RenderException(f"Invalid time grain '{time_grain}'")


class RasgoLoader(BaseLoader):
    def __init__(self, root_path=None):
        if not root_path:
            root_path = Path(__file__).parent.parent / "macros"
        self.root_path = root_path

    def get_source(self, environment: RasgoEnvironment, template):
        template_path = self.root_path / environment.dw_type.value / template
        if not template_path.exists():
            template_path = self.root_path / template
            if not template_path.exists():
                raise TemplateNotFound(template)
        mtime = getmtime(template_path)
        return template_path.read_text(), template_path, lambda: mtime == getmtime(template_path)
