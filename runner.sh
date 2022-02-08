#!/usr/bin/env bash
set -euo pipefail

## add to pre-commit
## https://github.com/jumanjihouse/pre-commit-hooks/blob/master/pre_commit_hooks/shellcheck
## https://github.com/jumanjihouse/pre-commit-hooks/blob/master/pre_commit_hooks/shfmt

# if aws_creds not given in environment, use default
if [[ ! -e .aws_creds ]]; then
read -p "Are you sure you want to continue without setting AWS credentials environment file'? (y/N)" -n 1 -r
	echo # intentional
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		cp .aws_creds.sample .aws_creds
		docker-compose build
		docker-compose up
	fi
fi