"""
Python Script to Publish all Transforms based off the YAML file definitions
within this Repo

Execute this script with PyRasgo in your python Environment
"""
import argparse

import pyrasgo

import utils
from constants import COMMUNITY_ORGANIZATION_ID


def publish_transforms(rasgo_api_key: str, rasgo_domain: str) -> None:
    """
    Publish/sync all the transforms in this repo with the db

    The logic for handling syncing transforms from this repo to the DB is described below
     - If a transform with that name and data warehouse doesn't exist in the DB create it
     - If a transform with that name and data warehouse exists in the DB, and one or more of its description,
        source_code, or arguments have changed, soft delete the transform in the DB,
        then create a new DB entry with the updated info
     - If there are no changes for that transform do nothing
     - Soft delete any transform with names that are still in the DB but don't exist in the UDT repo

    Args:
        rasgo_api_key: Rasgo APi key to use for connecting to the server
        rasgo_domain: Rasgo domain which sets which environment to call APi endpoints with
    """
    # Set RASGO_DOMAIN Env
    utils.set_rasgo_domain_env(rasgo_domain)

    # Get all Rasgo Transforms
    rasgo = pyrasgo.connect(rasgo_api_key)

    if rasgo.get.user().organization_id != COMMUNITY_ORGANIZATION_ID:
        raise Exception("You are not using the community organization role")

    rasgo_transforms = utils.get_all_rasgo_community_transform_keyed_by_name_and_dw_type(rasgo)

    # Keep track of which transforms in repo were published
    published_transform_names = []

    # Loop through all transform and respective data in this repo
    yaml_transforms = utils.load_all_yaml_files_as_dicts(utils.TRANSFORMS_ROOT / 'transforms')
    for transform_name, transform_yaml in yaml_transforms.items():

        # Load/parse needed transform data from YAML
        transform_description = transform_yaml.get('description')
        transform_source_code_variants = utils.get_transform_source_code_all_dws(transform_name=transform_name)
        transform_tags = utils.listify_tags(tags=transform_yaml.get('tags'))
        transform_args = utils.parse_transform_args_from_yaml(transform_yaml)
        transform_type = transform_yaml.get('type')
        transform_context = transform_yaml.get('context')

        # If a transform with that name isn't in Rasgo, create it
        for (name, dw), source_code in transform_source_code_variants.items():
            if dw not in ("GENERIC", "SNOWFLAKE", "BIGQUERY"):
                continue
            if (name, dw) not in rasgo_transforms:
                print(
                    f"No transform with name '{name}' for {dw.capitalize()} warehouse found in Rasgo. "
                    f"Creating new '{transform_name}' transform "
                    f"in Rasgo {rasgo_domain.upper()} environment."
                )

                rasgo.create.transform(
                    name=transform_name,
                    source_code=source_code,
                    arguments=transform_args,
                    description=transform_description,
                    tags=transform_tags,
                    type=transform_type,
                    context=transform_context,
                    dw_type=dw,
                )

            # If it does exist in Rasgo, check if anything in the
            # transform has changed. If so soft delete that transform
            # in the db, the re-create it with updated information
            else:
                curr_transform_in_db = rasgo_transforms[(transform_name, dw)]
                if utils.transform_needs_versioning(
                    transform=curr_transform_in_db,
                    source_code=source_code,
                    arguments=transform_args,
                    description=transform_description,
                    tags=transform_tags,
                    transform_type=transform_type,
                    context=transform_context,
                ):
                    print(
                        f"Versioning transform '{transform_name}'. Updates found "
                        f"in Rasgo {rasgo_domain.upper()} environment."
                    )
                    rasgo.delete.transform(curr_transform_in_db.id)
                    rasgo.create.transform(
                        name=transform_name,
                        source_code=source_code,
                        arguments=transform_args,
                        description=transform_description,
                        tags=transform_tags,
                        type=transform_type,
                        context=transform_context,
                        dw_type=dw,
                    )
                else:
                    print(
                        f"No updates found for {dw.capitalize()}'s '{transform_name}' transform "
                        f"found in Rasgo {rasgo_domain.upper()} environment."
                    )

            # Keep track of which transforms were versioned/published
            published_transform_names.append((name, dw))

    # Delete any transforms which are in db, but not in this repo
    transforms_to_delete = {
        (name, dw): t.id for (name, dw), t in rasgo_transforms.items() if (name, dw) not in published_transform_names
    }
    for (name, dw), transform_id in transforms_to_delete.items():
        print(
            f"Soft Deleting {dw.capitalize()}'s '{name}' transform with db id {transform_id} "
            f"in Rasgo {rasgo_domain.upper()} environment"
        )
        rasgo.delete.transform(transform_id)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('pyrasgo-api-key', action='store')
    arg_parser.add_argument(
        '-d',
        '--rasgo-domain',
        action='store',
        default='production',
        choices=['local', 'staging', 'production'],
        help="Rasgo Environment to connect to. Sets env var "
        "'RASGO_DOMAIN' for PyRasgo url dispatching "
        "(local, staging, or production).",
    )
    args = arg_parser.parse_args()

    # Publish all Transforms in this Repo
    # With Selected Rasgo API Key and Domain
    publish_transforms(rasgo_api_key=getattr(args, 'pyrasgo-api-key'), rasgo_domain=args.rasgo_domain)
