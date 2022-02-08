#! /usr/bin/env bash
set -euo pipefail

# sanity checks
ls -lat
printenv
source .envrc

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login \
    --username AWS \
    --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
docker build -t $APP_NAME:$APP_ENV -f Dockerfile \
    --build-arg AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    --build-arg AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    --build-arg AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID \
    --build-arg AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    --build-arg STAGE=$STAGE \
    --build-arg APP_ENV=$APP_ENV \
    --build-arg APP_NAME=$APP_NAME .
IMAGE=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$APP_NAME:$APP_ENV
docker tag $APP_NAME:$APP_ENV $IMAGE
