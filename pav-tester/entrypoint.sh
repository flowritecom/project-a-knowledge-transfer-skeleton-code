#!/usr/bin/env bash
set -euo pipefail

## add to pre-commit
## https://github.com/jumanjihouse/pre-commit-hooks/blob/master/pre_commit_hooks/shellcheck
## https://github.com/jumanjihouse/pre-commit-hooks/blob/master/pre_commit_hooks/shfmt


## make sure we have AWS credentials in scope
declare -a \
    aws_vars=(
        "APP_NAME"
        "APP_ENV"
        "STAGE"
        "VAR_STAGE"
        "AWS_ACCESS_KEY_ID"
        "AWS_ACCOUNT_ID"
        "AWS_SECRET_ACCESS_KEY"
        "AWS_DEFAULT_REGION")

# ${!aws_var} is a variable indirection.
# It expands to the value of the variable whose name is kept in $aws_var.
for aws_var in "${aws_vars[@]}"; do
    if [[ -z "${!aws_var}" ]]; then
        echo "Must provide ${aws_var} in environment" 1>&2
        exit 1
    fi
done

# print sanity checks and why not write into a file
# that can be checked and sent to central place to look up
# what is running where and how changes propagate
/opt/pysetup/.venv/bin/python <<EOF
import os
print(os.environ)
print(f"working directory for python:, {os.getcwd()}")
EOF

echo "realpath of entrypoint.sh: $(realpath .)"

# for private git repo - clone vars
# GITHUB_ACCESS_TOKEN=$(aws secretsmanager get-secret-value --secret-id general/github/access-token --query SecretString --output text | cut -d: -f2 | tr -d \"'}')
#git clone -b $STAGE https://oauth2:$GITHUB_ACCESS_TOKEN@github.com/flowritecom/vars.git /opt/pysetup/vars

git clone -b $STAGE https://github.com/flowritecom/project-a-knowledge-transfer-vars-repo.git /opt/pysetup/vars

# prestep, take the args from environment $NAME $STAGE
cp /opt/pysetup/vars/json/"$APP_NAME".json /opt/pysetup/vars/prestep.py /opt/pysetup/vars/get_secrets.py .
/opt/pysetup/.venv/bin/python prestep.py "$APP_NAME" "$VAR_STAGE"

ls -lat
ls -lat /opt/pysetup/.venv/
source .envrc
printenv

# print sanity checks 
/opt/pysetup/.venv/bin/python <<EOF
import os
print(os.environ)
EOF

#exec app
/opt/pysetup/.venv/bin/python <<EOF
from tests.main import main
if __name__ == '__main__':
    main()
EOF
