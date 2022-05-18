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
    else:
        return None


def get_path(transform_name: str, dw_type: Optional[DataWarehouse] = None) -> Optional[str]:
    root_dir = os.path.dirname(__file__)
    if dw_type:
        function_path = Path(root_dir, 'transforms', transform_name, dw_type.value,
                             f'{transform_name}.py')
        if os.path.exists(function_path):
            return str(function_path.absolute())
    function_path = Path(root_dir, 'transforms', transform_name, f'{transform_name}.py')
    if not os.path.exists(function_path):
        return None
    return str(function_path.absolute())


def import_from(module, name):
    module = __import__(module, fromlist=[name])
    return getattr(module, name)


def cleanse_name(symbol: str) -> str:
    """
    Extra verbose function for clarity

    remove double quotes
    replace spaces and dashes with underscores
    cast to upper case
    delete anything that is not letters, numbers, or underscores
    if first character is a number, add an underscore to the beginning
    """
    symbol = str(symbol)
    symbol = symbol.strip()
    symbol = symbol.replace(' ', '_').replace('-', '_')
    symbol = symbol.upper()
    symbol = re.sub('[^A-Z0-9_]+', '', symbol)
    # if symbol is empty, at least returns '_'
    # if starts with a decimal prefix with '_'
    symbol = '_' + symbol if symbol[0].isdecimal() or not symbol else symbol

    return symbol


def infer_columns(
        transform_name: str,
        transform_args: Dict[str, Any],
        source_columns: Dict[str, str],
        dw_type: Optional[str] = None
) -> Optional[Dict[str, str]]:
    dw_type = get_dw_type(dw_type)
    function_path = get_path(transform_name, dw_type)
    if function_path:
        cleaned_source_columns = {}
        for column_name, column_type in source_columns.items():
            cleaned_source_columns[cleanse_name(column_name)] = get_dtype(column_type)
        loader = machinery.SourceFileLoader(transform_name, function_path)
        spec = util.spec_from_loader(transform_name, loader)
        module = util.module_from_spec(spec)
        loader.exec_module(module)
        function = module.infer_columns
        output_columns = function(
            args=transform_args,
            source_columns=source_columns
        )
        cleaned_output_columns = {}
        for column_name, column_type in output_columns.items():
            cleaned_output_columns[cleanse_name(column_name)] = get_dtype(column_type)
        return cleaned_output_columns
    else:
        return None
