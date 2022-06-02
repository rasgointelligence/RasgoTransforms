import os
from typing import Dict, List, Tuple

import constants
import utils
import docs_markdown as md

DATASET_PREVIEW_TEXT = """Pull a source Dataset and preview it:"""
DATASET_PREVIEW_CODE = """ds = rasgo.get.dataset(id)\nprint(ds.preview())"""
TRANSFORMED_DATA_PREVIEW_TEXT = """Transform the Dataset and preview the result:"""


def save_transform_docs() -> None:
    """
    Load all transform YAML files, and write/overwrite them to their
    respective Transform Docs Dir

    If YAML file can't be loaded it will not write it
    """
    print('Generating Transform documentation markdown files...')
    file_path = utils.TRANSFORMS_ROOT / 'transforms'
    transforms = utils.load_all_yaml_files_as_dicts(file_path)
    for transform_name, transform_yaml in transforms.items():
        if utils.override_path_exists(file_path, transform_name, constants.RASGO_DATAWAREHOUSE):
            dw_type = constants.RASGO_DATAWAREHOUSE
        else:
            dw_type = None
        markdown = get_transform_markdown(
            transform_yaml=transform_yaml,
            transform_dir_name="transforms",
            transform_name=transform_name,
            dw_type=dw_type,
        )
        # Write Transform Markdown to Docs directory
        md_file_path = utils.DOCS_DIR / f"{transform_name}.md"
        md_file_path.parent.mkdir(exist_ok=True)
        md_file_path.write_text(markdown)


def generate_accelerator_docs():
    """
    Generate docs for all accelerators and save to to Acceletors docs dir
    """
    print('Generating Accelerator documentation markdown files...')
    accelerators = utils.load_all_yaml_files_as_dicts(utils.TRANSFORMS_ROOT / 'accelerators')

    accelerators_sub_dir = 'accelerators'
    accelerator_docs_path = utils.DOCS_DIR / accelerators_sub_dir
    accelerator_docs_path.mkdir(exist_ok=True)

    for name, accelerator in accelerators.items():
        markdown = get_accelerator_markdown(accelerator, accelerators_sub_dir, name)
        file_path = accelerator_docs_path / f'{name}.md'
        file_path.write_text(markdown)


def build_table(fields: List[str], table_dictionary: Dict[str, any]):
    """
    From transform args dict, make and return a markdown table of
    transform args descriptions
    """
    headers = ['Name'] + [' '.join([y.capitalize() for y in x.split('_')]) for x in fields]
    values = utils.get_table_values(fields, table_dictionary)
    return headers, values


def get_metrics_tables(output_tables: Dict[str, any]) -> List[str]:
    elements = []
    for table_name, table_dict in output_tables.items():
        elements.append(md.h3(table_name))
        elements.append(md.table(*build_table(['index', 'description', 'source'], table_dict['metrics'])))
    return elements


def get_transform_markdown(
    transform_yaml: Dict,
    transform_dir_name: str,
    transform_name: str,
    dw_type: str = None,
) -> str:
    """
    Generate and return the markdown string to write as a MD
    file for this transform based off the YAML file
    """
    # Generate Markdown Elements in Transform Doc
    markdown_elements = [
        '',
        md.h1(transform_yaml['name']),
        transform_yaml['description'],
        md.h2('Parameters'),
        md.table(*build_table(['type', 'description', 'is_optional'], transform_yaml['arguments'])),
        md.h2('Example'),
        DATASET_PREVIEW_TEXT if 'preview-data' in transform_yaml else None,
        md.python_code(DATASET_PREVIEW_CODE) if 'preview-data' in transform_yaml else None,
        transform_yaml['preview-data'] if 'preview-data' in transform_yaml else None,
        TRANSFORMED_DATA_PREVIEW_TEXT if 'preview-data' in transform_yaml else None,
        md.python_code(transform_yaml['example_code']),
        transform_yaml['post-transform-data'] if 'preview-data' in transform_yaml else None,
        md.h2('Source Code'),
        md.github_url(f'/{transform_dir_name}/{transform_name}/{dw_type+"/" if dw_type else ""}{transform_name}.sql'),
        '',
    ]
    return '\n\n'.join(filter(lambda x: x != None, markdown_elements))


def get_accelerator_markdown(accelerator: Dict[str, any], accelerators_path: str, accelerator_file_name: str) -> str:
    markdown_elements = [
        md.h1(accelerator['name']),
        accelerator['description'],
        md.h2('Parameters'),
        md.table(*build_table(['type', 'description', 'is_optional'], accelerator['arguments'])),
    ]

    if 'doc' in accelerator and 'output_tables' in accelerator['doc']:
        markdown_elements.extend([md.h2('Output Metrics')] + get_metrics_tables(accelerator['doc']['output_tables']))

    markdown_elements.extend([md.h2('Source Code'), md.github_url(f'/{accelerators_path}/{accelerator_file_name}.yml')])
    return '\n\n'.join(x for x in markdown_elements if x)


if __name__ == '__main__':
    save_transform_docs()
    generate_accelerator_docs()
