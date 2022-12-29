#!/bin/bash

CIRCLE_BRANCH=$1
MASTER_SHA=$2
CORE_VERSION=$3

generate_post_data()
{
  cat <<EOF
{
  "ref": "refs/heads/$CIRCLE_BRANCH",
  "sha": "$MASTER_SHA"
}
EOF
}

echo "$(generate_post_data)"

curl -X POST \
  https://api.github.com/repos/SpotIM/iOS-SDK-Test-Cocoapods-Integration/git/refs \
  -i -u "ios-dev-openweb:$GITHUB_OPENWEB_USER_TOKEN" \
  -H 'Accept: application/vnd.github.v3+json' \
  -d "$(generate_post_data)"
