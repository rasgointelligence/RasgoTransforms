from typing import Dict

from maintenance.docs_generation import utils, markdown as md


def save_transform_docs():
    transform_yamls = utils.load_all_yaml_files()
    for transform_type, transform_type_yamls in transform_yamls.items():
        for transform_name, transform_data in transform_type_yamls.items():
            print(f"Generating Markdown for Transform {transform_name}")
            markdown = _get_transform_markdown(
                transform_data=transform_data,
                transform_type=transform_type,
                transform_name=transform_name
            )



def _get_transform_markdown(transform_data: Dict,
                            transform_type: str,
                            transform_name: str) -> str:
    """

    :param transform_data:
    :return:
    """
    # Generate Markdown Elements in Transform Doc
    markdown_elements = [
        '',
        md.h1(transform_data['name']),
        transform_data['description'],
        md.h2('Parameters'),
        md.table(transform_data['arguments']),
        md.h2('Example'),
        md.python_code(transform_data['example_code']),
        md.h2('Source Code'),
        md.github_url(transform_type, transform_name),
        '',
    ]
    return '\n\n'.join(markdown_elements)



save_transform_docs()




