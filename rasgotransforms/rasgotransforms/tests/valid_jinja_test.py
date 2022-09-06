import logging

from jinja2 import meta
from jinja2.nodes import FromImport
import pytest

from rasgotransforms.main import TransformTemplate
from rasgotransforms.testing_utils import get_all_transform_templates, get_all_macros
from rasgotransforms.render import RasgoEnvironment

LOGGER = logging.getLogger(__name__)
MACROS = get_all_macros()
transforms = get_all_transform_templates()


class TestJinja:
    @pytest.mark.parametrize("transform", transforms, ids=[t.name for t in transforms])
    def test_transforms_jinja(self, transform: TransformTemplate):
        environment = RasgoEnvironment(dw_type=transform.dw_type, run_query=None)
        LOGGER.info(f'Validating {transform.name}')
        declared_arg_names = set([arg['name'] for arg in transform.arguments if arg['name'] != 'none']).union(
            {'source_table'}
        )
        global_arg_names = set([g for g in environment.rasgo_globals.keys()]).union({'get_columns'})
        parsed_template = environment.parse(transform.source_code)
        parsed_arg_names = meta.find_undeclared_variables(parsed_template)
        unused_args = list(declared_arg_names.difference(parsed_arg_names))
        if unused_args:
            pytest.fail(
                f"Transform '{transform.name}' declares args [{', '.join(unused_args)}] that "
                f"are not used in the template"
            )
        undeclared_args = list(parsed_arg_names.difference(declared_arg_names).difference(global_arg_names))
        if undeclared_args:
            LOGGER.warning(
                f"Transform '{transform.name}' contains undeclared variables "
                f"[{', '.join(undeclared_args)}] which are not declared as transform args"
            )
        referenced_templates = meta.find_referenced_templates(parsed_template)
        missing_templates = set(list(referenced_templates)).difference(set([template for template in MACROS.keys()]))
        if missing_templates:
            pytest.fail(
                f"Transform '{transform.name}' references template(s) [{', '.join(missing_templates)}] "
                f"which do not exist"
            )
        if referenced_templates:
            for node in parsed_template.body:
                if type(node) is FromImport:
                    missing_macros = set(node.names).difference(set(MACROS[node.template.value]))
                    if missing_macros:
                        pytest.fail(
                            f"Transform '{transform.name}' references macro(s) [{', '.join(missing_templates)}] "
                            f"which do not exist in template {node.template.value}"
                        )
