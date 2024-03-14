#!/bin/bash

date=$(date '+%d-%m-%Y')
branch="upload_s3/beta_app/nightly/develop/$date"
echo "Branch path: $branch"

git status
# git checkout apple_api_key.json
git config credential.helper 'cache --timeout=120'
git config --global user.email "ios-dev@openweb.com"
git config --global user.name "OpenWeb Mobile bot via CircleCI"
git checkout -b $branch
git commit --allow-empty -m "CircleCI nightly - building both .ipa and .app files to Amazon s3"
git push origin $branch
