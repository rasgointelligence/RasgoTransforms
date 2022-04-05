"""
Python Script to Publish all Transforms based off the YAML file definitions
within this Repo

Execute this script with a Installed selected Version of PyRasgo in your
python Environment
"""
import argparse

import pyrasgo

import utils


def publish_transforms(rasgo_api_key: str, rasgo_domain: str) -> None:
    """
    Publish/sync all the transforms in this repo with the db

    The logic for handling syncing transforms from this repo to the DB is described below
     - If a transform with that name doesn't exist in the DB create it
     - If a transform with that name exists in the DB, and one or more of its description, source_code, or
       arguments have changed, soft delete the transform in the DB, then create a new DB entry with the updated info
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
    rasgo_transforms = utils.get_all_rasgo_transform_keyed_by_name(rasgo)

    # Keep track of which transforms in repo were published
    published_transform_names = []

    # Loop through all transform and respective data in this repo
    yaml_transforms = utils.load_all_yaml_files()
    for transform_name, transform_yaml in yaml_transforms.items():

        # Load/parse needed transform data from YAML
        transform_description = transform_yaml.get('description')
        transform_source_code = utils.get_transform_source_code(
            transform_name=transform_name
        )
        transform_tags = utils.listify_tags(
            tags=transform_yaml.get('tags')
        )
        transform_args = utils.parse_transform_args_from_yaml(transform_yaml)

        # If a transform with that name isn't in Rasgo, create it
        if transform_name not in rasgo_transforms:
            print(f"No transform with name '{transform_name}' found in Rasgo. "
                    f"Creating new '{transform_name}' transform "
                    f"in Rasgo {rasgo_domain.upper()} environment.")
            rasgo.create.transform(
                name=transform_name,
                source_code=transform_source_code,
                arguments=transform_args,
                description=transform_description,
                tags=transform_tags
            )

        # If it does exist in Rasgo, check if anything in the
        # transform has changed. If so soft delete that transform
        # in the db, the re-create it with updated information
        else:
            curr_transform_in_db = rasgo_transforms[transform_name]
            if utils.transform_needs_versioning(
                    transform=curr_transform_in_db,
                    source_code=transform_source_code,
                    arguments=transform_args,
                    description=transform_description,
                    tags=transform_tags
            ):
                print(f"Versioning transform '{transform_name}'. Updates found "
                        f"in Rasgo {rasgo_domain.upper()} environment.")
                rasgo.delete.transform(curr_transform_in_db.id)
                rasgo.create.transform(
                    name=transform_name,
                    source_code=transform_source_code,
                    arguments=transform_args,
                    description=transform_description,
                    tags=transform_tags
                )
            else:
                print(f"No updates found for '{transform_name}' transform "
                        f"found in Rasgo {rasgo_domain.upper()} environment.")

        # Keep track of which transforms were versioned/published
        published_transform_names.append(transform_name)

    # Delete any transforms which are in db, but not in this repo
    transforms_to_delete = {
        transform_name: t.id for transform_name, t in rasgo_transforms.items()
        if transform_name not in published_transform_names
    }
    for transform_name, transform_id in transforms_to_delete.items():
        print(f"Soft Deleting '{transform_name}' transform with db id {transform_id} "
              f"in Rasgo {rasgo_domain.upper()} environment")
        rasgo.delete.transform(transform_id)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('pyrasgo-api-key', action='store')
    arg_parser.add_argument('-d', '--rasgo-domain',
                            action='store',
                            default='production',
                            choices=['local', 'staging', 'production'],
                            help="Rasgo Environment to connect to. Sets env var "
                                 "'RASGO_DOMAIN' for PyRasgo url dispatching "
                                 "(local, staging, or production).")
    args = arg_parser.parse_args()

    # Publish all Transforms in this Repo
    # With Selected Rasgo API Key and Domain
    publish_transforms(
        rasgo_api_key=getattr(args, 'pyrasgo-api-key'),
        rasgo_domain=args.rasgo_domain
    )
