import os
from typing import Callable, Dict, Optional, Union
from pathlib import Path
import inspect
import yaml

from .environment import RasgoEnvironment
from .main import DataWarehouse


class Transforms(object):
    """
    Dynamically adds class methods which render each transform in the package
    """

    def __init__(self, dw_type: str, run_query: Optional[Callable] = None):
        self.dw_type = DataWarehouse(dw_type.lower())
        self.run_query = run_query
        self.env = RasgoEnvironment(run_query=run_query)
        transforms_dir = Path(os.path.dirname(__file__), 'transforms')
        for transform_path in transforms_dir.rglob('*/*.yaml'):
            with open(transform_path) as fp:
                transform_config = yaml.safe_load(fp)
            setattr(self.__class__, transform_config['name'], self._get_render_method(transform_config))

    def _get_render_method(self, transform_config):
        """
        Creates the class method used to render jinja templates which is dynamically added to the transforms module
        """

        def render_transform(
            *args,
            source_table: str,
            source_columns: Optional[Union[Dict[str, Dict[str, str]], Callable]] = None,
            **kwargs,
        ) -> str:
            template_path = _get_transform_path(name=transform_config['name'], dw_type=self.dw_type)
            with open(template_path) as fp:
                source_code = fp.read()
            return self.env.render(
                source_code=source_code, source_table=source_table, arguments=kwargs, source_columns=source_columns
            )

        render_transform.__name__ = transform_config['name']
        render_transform.__signature__ = _gen_method_signature(render_transform, transform_config)
        render_transform.__doc__ = _gen_method_docstring(transform_config)
        return render_transform


def _gen_method_signature(udt_func: Callable, transform_config: Dict) -> inspect.Signature:
    """
    Creates and returns a method signature.

    This is shown documentation for the parameters when hitting shift tab in a notebook
    """
    # Get current signature of function
    sig = inspect.signature(udt_func)

    params = []
    # Create Signature Params for Transform Args
    for arg in transform_config['arguments']:
        p = inspect.Parameter(name=arg, kind=inspect.Parameter.KEYWORD_ONLY)
        params.append(p)

    params += [
        inspect.Parameter(name='source_table', kind=inspect.Parameter.KEYWORD_ONLY),
        inspect.Parameter(name='source_columns', kind=inspect.Parameter.KEYWORD_ONLY),
    ]

    return sig.replace(parameters=params)


def _gen_method_docstring(transform_config: Dict) -> str:
    """
    Generate and return a docstring for a transform method
    with transform description, args, and return specified.
    """
    # Have start of docstring be transform description
    docstring = f"\n{transform_config['description']}"

    # Add transform args to func docstring
    docstring = f"{docstring}\n  Args:"
    for arg, arg_meta in transform_config['arguments'].items():
        docstring = f"{docstring}\n    {arg}: {arg_meta['description']}"

    # Add return to docstring
    docstring = (
        f"{docstring}\n\n  Returns:\n    Returns an the rendered sql for the " f"{transform_config['name']} transform"
    )
    return docstring


def _get_transform_path(name: str, dw_type: DataWarehouse):
    """
    Returns the default or data warehouse specific template file given the transform name
    """
    root_dir = os.path.dirname(__file__)
    if dw_type:
        function_path = Path(root_dir, 'transforms', name, dw_type.value, f'{name}.sql')
        if function_path.exists():
            return str(function_path.absolute())
    function_path = Path(root_dir, 'transforms', name, f'{name}.sql')
    if os.path.exists(function_path):
        return str(function_path)
