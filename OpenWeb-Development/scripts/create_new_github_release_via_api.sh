#!/bin/bash

RELEASE_VERSION=$1

generate_post_data()
{
  cat <<EOF
{ 
  "name": "Version $RELEASE_VERSION",
  "body": "TODO fill in the body. (Generated via CircleCI - release_sdk_job)",
  "draft": true,
  "tag_name": "$RELEASE_VERSION"
}
EOF
}


echo "$(generate_post_data)"

curl -X POST \
  https://api.github.com/repos/SpotIM/spotim-ios-sdk-pod/releases \
  -i -u "ios-dev-openweb:$GITHUB_OPENWEB_USER_TOKEN" \
  -H 'Accept: application/vnd.github.v3+json' \
  -d "$(generate_post_data)"

