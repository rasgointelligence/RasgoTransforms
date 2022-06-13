from jinja2 import Environment
from typing import Callable, Dict, Optional, Tuple, Union
from itertools import combinations, permutations, product
import re

JINJA_ENV = Environment(extensions=['jinja2.ext.do', 'jinja2.ext.loopcontrols'])


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


def render(
    source_code: str,
    source_table: str,
    arguments: dict,
    source_columns: Optional[Union[Dict[str, Dict[str, str]], Callable]] = None,
    run_query: Optional[Callable] = None,
) -> str:
    """
    Given the source code of a jinja template, its arguments, and metadata about the source table,
    this renders the transform sql.

    Source columns can be a mapping of table names to columns (e.g. {table_name: {column_name: column_type}})
    or a function which returns a mapping of columns names to column types given a table fqtn
    (e.g. get_columns(fqtn): return {column_name: column_type}

    Run Query is a function which takes arbitrary sql and executes it agains the data warehouse. The data must be
    returned as a Pandas dataframe
    """
    arguments['source_table'] = source_table
    if source_columns and type(source_columns) is dict:

        def get_columns(fqtn):
            return source_columns[fqtn]

    else:
        get_columns = source_columns

    template_fns = {
        "run_query": run_query,
        "cleanse_name": cleanse_template_symbol,
        "raise_exception": raise_exception,
        "get_columns": get_columns,
        "itertools": {"combinations": combinations, "permutations": permutations, "product": product},
    }
    template = JINJA_ENV.from_string(source_code)
    rendered = template.render(**arguments, **template_fns)
    return rendered
