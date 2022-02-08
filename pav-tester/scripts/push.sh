#! /usr/bin/env bash
set -euo pipefail

# sanity checks
ls -lat
printenv
source .envrc

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login \
    --username AWS \
    --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$APP_NAME:$APP_ENV
docker push $IMAGE

# manifest sha256 that AWS uses is only created after the image is pushed
# that is the reason we do this as the last step
# we produce it to Buildkite as a txt artifact
# so we can pass it to the terraform/nixos deploy step
# to force refresh of the running container system daemon (if container rebuilt)
aws ecr get-login-password --region eu-central-1 | skopeo login \
    --authfile auth.json \
    --tmpdir /tmp \
    --username AWS \
    --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
skopeo inspect --authfile auth.json --tmpdir /tmp docker://$IMAGE | jq -r '.Digest' > image_sha256.txt
