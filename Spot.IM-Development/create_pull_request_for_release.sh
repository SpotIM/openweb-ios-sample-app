#!/bin/bash

RELEASE_VERSION=$1
CIRCLE_BRANCH=$2


generate_post_data()
{
  cat <<EOF
{ 
  "title": "SDK Release $RELEASE_VERSION",
  "body": "Generated via CircleCI release_sdk_job",
  "head": "$CIRCLE_BRANCH",
  "base": "master"
}
EOF
}


echo "$(generate_post_data)"


curl -X POST \
  https://api.github.com/repos/SpotIM/spotim-ios-sdk-demo-apps/pulls \
  -i -u "ios-dev-openweb:$GITHUB_OPENWEB_USER_TOKEN" \
  -H 'Accept: application/vnd.github.v3+json' \
  -d "$(generate_post_data)"

