import argparse
import os
from typing import Dict, List, Any

import pyrasgo

from python import utils, markdown as md

DOCS_DIR = utils.get_root_dir() / 'docs'

DATASET_PREVIEW_TEXT = """Pull a source Dataset and preview it:"""

DATASET_PREVIEW_CODE = """ds = rasgo.get.dataset(id)\nprint(ds.preview())"""

TRANSFORMED_DATA_PREVIEW_TEXT = """Transform the Dataset and preview the result:"""



def save_transform_docs(
    rasgo_api_key: str
) -> None:
    """
    Load all transform YAML files, and write/overwrite them to their
    respective Transform Docs Dir

    If YAML file can't be loaded it will not write it
    """
    # Connect to Rasgo to pass connection object to transform markdown
    # generation method
    rasgo = pyrasgo.connect(rasgo_api_key)
    
    transform_yamls = utils.load_all_yaml_files()
    for transform_type, transform_type_yamls in transform_yamls.items():
        transform_type_dir_name = f"{transform_type}_transforms"
        for transform_name, transform_yaml in transform_type_yamls.items():
            print(f"Generating Markdown for Transform "
                  f"'{transform_type_dir_name}/{transform_name}.yaml'")
            markdown = _get_transform_markdown(
                transform_yaml=transform_yaml,
                transform_type_dir_name=transform_type_dir_name,
                transform_name=transform_name,
                rasgo_connection=rasgo
            )
            # Write Transform Markdown to Docs directory
            md_file_path = DOCS_DIR / transform_type_dir_name / f"{transform_name}.md"
            os.makedirs(md_file_path.parent, exist_ok=True)
            with md_file_path.open('w') as fp:
                print(f"Writing Markdown docs at {md_file_path}\n")
                fp.write(markdown)


def _get_transform_markdown(
    transform_yaml: Dict,
    transform_type_dir_name: str,
    transform_name: str,
    rasgo_connection: Any
) -> str:
    """
    Generate and return the markdown string to write as a MD
    file for this transform based off the YAML file
    """
    # Get markdown representations for pre and post-transform datasets
    t1, t2 = _generate_dataset_markdowns(
        rasgo=rasgo_connection,
        dataset_id=transform_yaml['dataset-id'],
        output_cols=transform_yaml['output-cols'],
        transform_args=transform_yaml['transform-args']
    )

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
        t1,# md.text(transform_yaml['preview-data']) if 'preview-data' in transform_yaml else None,
        md.text(TRANSFORMED_DATA_PREVIEW_TEXT) if 'preview-data' in transform_yaml else None,
        md.python_code(transform_yaml['example_code']),
        t2,# md.text(transform_yaml['post-transform-data']) if 'preview-data' in transform_yaml else None,
        md.h2('Source Code'),
        md.github_url(transform_type_dir_name, transform_name),
        '',
    ]
    return '\n\n'.join(filter(lambda x: x!=None, markdown_elements))

def _generate_dataset_markdowns(
    rasgo: Any,
    dataset_id: int,
    output_cols: List[str],
    transform_details: Dict
) -> List[str]:
    """Creates markdown representation of both a pre-transform Rasgo Dataset
    and a transformed Rasgo Dataset

    Arguments:
        :dataset_id: int: A Rasgo Community Dataset ID matching the columns named 
        in the `example_code` section of the YAML doc
        :output_cols: List[str]: A list of column names to include in the output
        YAML representation
        :transform_args: dict: TODO what do we want here? How to build the transform from args
    """
    ds = rasgo.get.dataset(dataset_id)
    ds_md = ds.preview()[output_cols].to_markdown()

    ds1 = ds.transform(
        transform_name=transform_details["transform-name"],
        arguments=transform_details["transform-args"]
    )
    ds1_md = ds1.preview().to_markdown()

    return[ds_md, ds1_md]

if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('pyrasgo-api-key', action='store')
    args = arg_parser.parse_args()


    save_transform_docs(
        rasgo_api_key=getattr(args, 'pyrasgo-api-key')
    )
