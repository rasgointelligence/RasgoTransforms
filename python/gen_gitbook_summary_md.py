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
        transform_names=transforms_by_tag.pop('all')
    )

    # Make a section for all transform of a certain tag type
    # Show alphabetically
    for tag, transform_names in sorted(transforms_by_tag.items()):
        summary_md_txt += _gen_transform_section(
            section_name=tag,
            transform_names=transforms_by_tag[tag]
        )

    # Write out text to file in repo
    out_file_path = utils.get_root_dir() / 'docs' / 'gitbook' / 'transforms_summary.md'
    os.makedirs(out_file_path.parent, exist_ok=True)
    with out_file_path.open('w') as fp:
        print(f"Writing Transform Gitbook SUMMARY.md text to {out_file_path}\n")
        fp.write(summary_md_txt)


def _gen_transform_section(
        section_name: str,
        transform_names: List[str]
) -> str:
    """"""
    # Make link to README.md for transform section
    section_name_url_escaped = section_name.replace('_', '-')
    out_txt = f"* [{utils.snack_case_to_title(section_name)} Transforms]" \
              f"(transforms/{section_name_url_escaped}-transforms/README.md)\n"

    # Add sub pages for each transform in section
    # Sort transform names so shown Alphabetically in Gitbook
    # HREF will always link to same doc for each transform
    sorted(transform_names)
    for transform_name in transform_names:
        transform_name_url_escaped = transform_name.replace('_', '\_')
        out_txt += f"  * [{utils.snack_case_to_title(transform_name)}]" \
                   f"(transforms/all-transforms/{transform_name_url_escaped}.md)\n"
    return out_txt


if __name__ == "__main__":
    gen_gitbook_summary_md()
