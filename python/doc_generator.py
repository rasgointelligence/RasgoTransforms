import os
from typing import Dict

from python import constants, utils, markdown as md

DOCS_DIR = utils.get_root_dir() / 'docs'

DATASET_PREVIEW_TEXT = """Pull a source Dataset and preview it:"""

DATASET_PREVIEW_CODE = """ds = rasgo.get.dataset(id)\nprint(ds.preview())"""

TRANSFORMED_DATA_PREVIEW_TEXT = """Transform the Dataset and preview the result:"""


def save_transform_docs() -> None:
    """
    Load all transform YAML files, and write/overwrite them to their
    respective Transform Docs Dir

    If YAML file can't be loaded it will not write it
    """
    transform_yamls = utils.load_all_yaml_files()
    for transform_type, transform_type_yamls in transform_yamls.items():
        transform_type_dir_name = f"{transform_type}_transforms"
        for transform_name, transform_yaml in transform_type_yamls.items():
            print(f"Generating Markdown for Transform "
                  f"'{transform_type_dir_name}/{transform_name}.yaml'")
            if utils.override_path_exists(
                    transform_type,
                    transform_name,
                    constants.RASGO_DATAWAREHOUSE
                ):
                dw_type = constants.RASGO_DATAWAREHOUSE
            else:
                dw_type = None
            markdown = _get_transform_markdown(
                transform_yaml=transform_yaml,
                transform_type_dir_name=transform_type_dir_name,
                transform_name=transform_name,
                dw_type=dw_type
            )
            # Write Transform Markdown to Docs directory
            md_file_path = DOCS_DIR / transform_type_dir_name / f"{transform_name}.md"
            os.makedirs(md_file_path.parent, exist_ok=True)
            with md_file_path.open('w') as fp:
                print(f"Writing Markdown docs at {md_file_path}\n")
                fp.write(markdown)


def _get_transform_markdown(transform_yaml: Dict,
                            transform_type_dir_name: str,
                            transform_name: str,
                            dw_type: str = None
                            ) -> str:
    """
    Generate and return the markdown string to write as a MD
    file for this transform based off the YAML file
    """
    # Generate Markdown Elements in Transform Doc
    markdown_elements = [
        '',
        md.h1(transform_yaml['name']),
        md.text(transform_yaml['description']),
        md.h2('Parameters'),
        md.table(transform_yaml['arguments']),
        md.h2('Example'),
        md.text(DATASET_PREVIEW_TEXT) if 'preview-data' in transform_yaml else None,
        md.python_code(DATASET_PREVIEW_CODE) if 'preview-data' in transform_yaml else None,
        md.text(transform_yaml['preview-data']) if 'preview-data' in transform_yaml else None,
        md.text(TRANSFORMED_DATA_PREVIEW_TEXT) if 'preview-data' in transform_yaml else None,
        md.python_code(transform_yaml['example_code']),
        md.text(transform_yaml['post-transform-data']) if 'preview-data' in transform_yaml else None,
        md.h2('Source Code'),
        md.github_url(transform_type_dir_name, transform_name, dw_type),
        '',
    ]
    return '\n\n'.join(filter(lambda x: x!=None, markdown_elements))


if __name__ == '__main__':
    save_transform_docs()
