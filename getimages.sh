#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

for REGION in $(cat regions.txt); do
  aws --region=${REGION} ec2 describe-images \
    --filters Name=is-public,Values=true \
    | jq '.Images | sort_by(.CreationDate)' > ${REGION}.json &
done

xz -T0 -9 -v *.json
ls -alh