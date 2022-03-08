"""
TODO: Fill this
"""
import os
from typing import List

import utils


def gen_gitbook_summary_md() -> None:
    """

    Returns:

    """
    summary_md_txt = ""
    transforms_by_tag = utils.get_transforms_grouped_by_tags()

    # Make sure 'All Transforms' Section goes above others
    # in Gitbook's SUMMARY.md file
    summary_md_txt += _gen_transform_section(
        section_name='all',
        transform_names=transforms_by_tag.pop('all'),
        indent_level=0,
        add_transforms_to_section_title=True
    )

    # Create section for people ro View Transforms by Category
    summary_md_txt += f"* [Transform Categories]()\n"

    # Make a sub section for all transform of a certain tag type
    # Show alphabetically
    for tag, transform_names in sorted(transforms_by_tag.items()):
        summary_md_txt += _gen_transform_section(
            section_name=tag,
            transform_names=transforms_by_tag[tag],
            indent_level=1
        )

    # Write out text to file in repo
    out_file_path = utils.get_root_dir() / 'docs' / 'gitbook' / 'transforms_summary.md'
    os.makedirs(out_file_path.parent, exist_ok=True)
    with out_file_path.open('w') as fp:
        print(f"Writing Transform Gitbook SUMMARY.md text to {out_file_path}\n")
        fp.write(summary_md_txt)


def _gen_transform_section(
        section_name: str,
        transform_names: List[str],
        indent_level: int = 0,
        add_transforms_to_section_title: bool = False
) -> str:
    """"""
    # Init subsection top level link
    # We leave HREF empty here, since gitbook would auto populate it with transforms we add below
    if add_transforms_to_section_title:
        out_txt = f"{indent_level * '  '}* [{utils.snack_case_to_title(section_name)} Transforms]()\n"
    else:
        out_txt = f"{indent_level * '  '}* [{utils.snack_case_to_title(section_name)}]()\n"

    # Add sub pages for each transform in section
    # Sort transform names so shown Alphabetically in Gitbook
    # HREF will always link to same doc for each transform
    for transform_name in sorted(transform_names):
        transform_name_url_escaped = transform_name.replace('_', '\_')
        out_txt += f"{indent_level * '  '}  * [{utils.snack_case_to_title(transform_name)}]" \
                   f"(transforms/all-transforms/{transform_name_url_escaped}.md)\n"
    return out_txt


if __name__ == "__main__":
    gen_gitbook_summary_md()
