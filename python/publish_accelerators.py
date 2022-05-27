"""
Python Script to Publish all Accelerators based off the YAML file definitions
within this Repo
"""
import argparse
import json

import pyrasgo

import utils
from constants import COMMUNITY_ORGANIZATION_ID


def publish_accelerators(rasgo_api_key: str, rasgo_domain: str) -> None:
    """
    Delete all accelerators that have been changed or no longer exist
    Add new Accelerators and Accelerators with new definitions
    """
    # Set RASGO_DOMAIN Env
    utils.set_rasgo_domain_env(rasgo_domain)

    # Get all published Rasgo Accelerators
    rasgo = pyrasgo.connect(rasgo_api_key)
    if rasgo.get.user().organization_id != COMMUNITY_ORGANIZATION_ID:
        raise PermissionError("You are not using the community organization role")
    rasgo_acclerators = rasgo.get.accelerators()

    # Get the list of Accelerators in this repo
    local_accelerators = []
    path = utils.TRANSFORMS_ROOT / 'accelerators'
    files = list(path.rglob("*.yml")) + list(path.rglob("*.yaml"))
    for file in files:
        with open(file, "r") as stream:
            local_accelerators.append(rasgo.create._build_accelerator(stream.read()))

    # jsonify accelerators and use those to do a full object comparison
    rasgo_set = set(x.json() for x in  [pyrasgo.schemas.AcceleratorCreate(**(x.__dict__)) for x in rasgo_acclerators])
    local_set = set(x.json() for x in local_accelerators)

    # get set of items to add and delete. If a definition has changed, it will be deleted and re-added
    to_delete = [json.loads(x)['name'] for x in (rasgo_set - local_set)]
    to_add = [json.loads(x)['name'] for x in (local_set - rasgo_set)]

    if not to_delete and not to_add:
        print('No Accelerators to update')
        return
    
    print("Updating Accelerators:")
    print(f'U {u}\n' for u in set(to_delete) & set(to_add))
    print(f'D {d}\n' for d in set(to_delete) - set(to_add))
    print(f'A {a}\n' for a in set(to_add) - set(to_delete))

    for delete in to_delete:
        rasgo.delete.accelerator(next(iter([x for x in rasgo_acclerators if x.name == delete])).id)
    
    for add in to_add:
        rasgo.create.accelerator(accelerator_create=next(iter([x for x in local_accelerators if x.name == add])))


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

    publish_accelerators(rasgo_api_key=getattr(args, 'pyrasgo-api-key'), rasgo_domain=args.rasgo_domain)
