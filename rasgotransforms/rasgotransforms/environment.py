from jinja2 import Environment
import re
from datetime import datetime
from itertools import combinations, permutations, product
from typing import Callable, Optional, Union, Dict


class Renderer(Environment):
    def __init__(self, run_query: Callable, *args, **kwargs):
        super().__init__()
        self.jinja_environment = Environment(*args, extensions=['jinja2.ext.do', 'jinja2.ext.loopcontrols'], **kwargs)
        self.jinja_environment.filters['todatetime'] = datetime.fromisoformat
        self.jinja_environment.globals = self._source_code_functions()
        self.jinja_environment.globals['run_query'] = run_query

    def _source_code_functions(self):
        return {
            "cleanse_name": cleanse_template_symbol,
            "raise_exception": raise_exception,
            "itertools": {"combinations": combinations, "permutations": permutations, "product": product},
        }

    def render(
        self,
        source_code: str,
        source_table: str,
        arguments: dict,
        source_columns: Optional[Union[Dict[str, Dict[str, str]], Callable]] = None,
    ) -> str:
        """
        Given the source code of a jinja template, its arguments, and metadata about the source table,
        this renders the transform sql.

        Source columns can be a mapping of table names to columns (e.g. {table_name: {column_name: column_type}})
        or a function which returns a mapping of columns names to column types given a table fqtn
        (e.g. get_columns(fqtn): return {column_name: column_type}
        """
        arguments['source_table'] = source_table
        if source_columns and type(source_columns) is dict:

            def get_columns(fqtn):
                return source_columns[fqtn]

        else:
            get_columns = source_columns

        template_fns = {
            "get_columns": get_columns,
        }
        template = self.jinja_environment.from_string(source_code)
        rendered = template.render(**arguments, **template_fns)
        return rendered


def cleanse_template_symbol(symbol: str) -> str:
    symbol = str(symbol)
    symbol = symbol.strip()
    symbol = symbol.replace(' ', '_').replace('-', '_')
    symbol = symbol.upper()
    symbol = re.sub('[^A-Z0-9_]+', '', symbol)
    symbol = '_' + symbol if symbol[0].isdecimal() or not symbol else symbol

    return symbol


def raise_exception(message: str) -> None:
    raise Exception(message)
