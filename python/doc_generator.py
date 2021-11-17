import os
from typing import Dict

from python import utils, markdown as md

DOCS_DIR = utils.get_root_dir() / 'docs'


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
            markdown = _get_transform_markdown(
                transform_yaml=transform_yaml,
                transform_type_dir_name=transform_type_dir_name,
                transform_name=transform_name
            )
            # Write Transform Markdown to Docs directory
            md_file_path = DOCS_DIR / transform_type_dir_name / f"{transform_name}.md"
            os.makedirs(md_file_path.parent, exist_ok=True)
            with md_file_path.open('w') as fp:
                print(f"Writing Markdown docs at {md_file_path}\n")
                fp.write(markdown)


def _get_transform_markdown(transform_yaml: Dict,
                            transform_type_dir_name: str,
                            transform_name: str) -> str:
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
        md.python_code(transform_yaml['example_code']),
        md.h2('Source Code'),
        md.github_url(transform_type_dir_name, transform_name),
        '',
    ]
    return '\n\n'.join(markdown_elements)


if __name__ == '__main__':
    save_transform_docs()
