#!/bin/bash

RELEASE_VERSION=$1
CIRCLE_BRANCH=$2


git status
# git checkout apple_api_key.json
git add .
git status
git config credential.helper 'cache --timeout=120'
git config --global user.email "odedre@gmail.com"
git config --global user.name "Oded Regev via CircleCI"
git commit -m "CircleCI update to version $RELEASE_VERSION [skip ci]"
git tag $RELEASE_VERSION
git remote -v
git remote set-url origin git@odedre.bitbucket.org:zencitytech/zencity-ios-app.git
git remote -v
git push origin $CIRCLE_BRANCH
git push origin --tags
