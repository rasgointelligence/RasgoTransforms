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

    failures = []

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
            try:
                local_accelerators.append(rasgo.create._build_accelerator(stream.read()))
            except Exception as e:
                failures.append(f'Failed to parse accelerator definition {file.stem}: {str(e)}')

    # jsonify accelerators and use those to do a full object comparison
    rasgo_set = set(x.json() for x in [pyrasgo.schemas.AcceleratorCreate(**(x.__dict__)) for x in rasgo_acclerators])
    local_set = set(x.json() for x in local_accelerators)

    # get set of items to add and delete. If a definition has changed, it will be deleted and re-added
    to_delete = [json.loads(x)['name'] for x in (rasgo_set - local_set)]
    to_add = [json.loads(x)['name'] for x in (local_set - rasgo_set)]

    if not to_delete and not to_add and not failures:
        print('\nNo Accelerators to update')
        return

    # calculate updated, added, deleted
    print("\nUpdating Accelerators:")
    updated = set(to_delete) & set(to_add)
    deleted = set(to_delete) - set(to_add)
    added = set(to_add) - set(to_delete)

    if updated:
        print(f'U {chr(10).join(u for u in updated)}')
    if deleted:
        print(f'D {chr(10).join(d for d in deleted)}')
    if added:
        print(f'A {chr(10).join(a for a in added)}')

    for delete in to_delete:
        try:
            rasgo.delete.accelerator(next(iter([x for x in rasgo_acclerators if x.name == delete])).id)
        except Exception as e:
            failures.append(f'Failed to delete accelerator {delete}: {str(e)}')

    for add in to_add:
        try:
            rasgo.create.accelerator(accelerator_create=next(iter([x for x in local_accelerators if x.name == add])))
        except Exception as e:
            failures.append(f'Failed to add accelerator {add}: {str(e)}')

    if failures:
        print('\nFailures:\n' + '\n'.join(failures) + '\n')
        raise RuntimeError('Encountered failures updating Accelerators!')


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
