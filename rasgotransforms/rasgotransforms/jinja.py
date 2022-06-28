from typing import Callable, Dict, Optional, Tuple, Union
from .environment import Renderer


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
    renderer = Renderer(run_query=run_query)
    return renderer.render(
        source_code=source_code, source_table=source_table, arguments=arguments, source_columns=source_columns
    )
