"""
Functions to render Transform Templates
"""
from typing import Dict, Any, Optional
from pathlib import Path
from .main import DataWarehouse
from .dtypes import DTYPES
from importlib import machinery, util
import os
import re


def get_dtype(dtype: str) -> str:
    return DTYPES[dtype.lower()]


def get_dw_type(dw_type: str) -> Optional[DataWarehouse]:
    if dw_type:
        try:
            return DataWarehouse[dw_type.upper()]
        except KeyError:
            raise Exception(f'Unsupported DataWarehouse type: {dw_type}')


def get_path(transform_name: str, dw_type: Optional[DataWarehouse] = None) -> Optional[str]:
    """
    Gets the python file for the given transform specific to the given data warehouse if one exists
    """
    root_dir = os.path.dirname(__file__)
    if dw_type:
        function_path = Path(root_dir, 'transforms', transform_name, dw_type.value, f'{transform_name}.py')
        if function_path.exists():
            return str(function_path.absolute())
    function_path = Path(root_dir, 'transforms', transform_name, f'{transform_name}.py')
    if os.path.exists(function_path):
        return str(function_path)


def cleanse_name(symbol: str) -> str:
    """
    Extra verbose function for clarity

    remove double quotes
    replace spaces and dashes with underscores
    cast to upper case
    delete anything that is not letters, numbers, or underscores
    if first character is a number, add an underscore to the beginning
    """
    symbol = str(symbol).strip().replace(' ', '_').replace('-', '_').upper()
    symbol = re.sub('[^A-Z0-9_]+', '', symbol)
    # if symbol is empty, at least returns '_'
    # if starts with a decimal prefix with '_'
    symbol = f'_{symbol}' if not symbol or symbol[0].isdecimal() else symbol

    return symbol


def infer_columns(
    transform_name: str, transform_args: Dict[str, Any], source_columns: Dict[str, str], dw_type: Optional[str] = None
) -> Optional[Dict[str, str]]:
    """
    Infers the column names and types in the output table from a query produced by a transform given
    the transform name, args, source columns, and data warehouse type
    """
    dw_type = get_dw_type(dw_type)
    function_path = get_path(transform_name, dw_type)
    if not function_path:
        return None
    cleaned_source_columns = {}
    for column_name, column_type in source_columns.items():
        cleaned_source_columns[cleanse_name(column_name)] = get_dtype(column_type)
    loader = machinery.SourceFileLoader(transform_name, function_path)
    spec = util.spec_from_loader(transform_name, loader)
    module = util.module_from_spec(spec)
    loader.exec_module(module)
    output_columns = module.infer_columns(args=transform_args, source_columns=source_columns)
    return {cleanse_name(name): get_dtype(column_type) for name, column_type in output_columns.items()}
