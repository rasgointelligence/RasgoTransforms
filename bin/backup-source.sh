#!/bin/sh

set -e;

# zip up the repo
zip -r ./rasgo-transforms.zip *

# upload it to s3
export AWS_DEFAULT_REGION=us-east-1
aws s3 cp rasgo-transforms.zip s3://rasgo-source-backups/rasgo-transforms.zip --storage-class GLACIER_IR

# clean up clean up everybody do your share
rm ./rasgo-transforms.zip
