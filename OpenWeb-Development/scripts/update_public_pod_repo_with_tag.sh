#!/bin/bash

RELEASE_VERSION=$1
XCODE_VERSION=$2
TAG="$RELEASE_VERSION-xcode$XCODE_VERSION"

git clone git@github.com:SpotIM/openweb-ios-sdk-pod.git
cd openweb-ios-sdk-pod
#git checkout -b $TAG
git checkout -b "testing-integration-$TAG"
echo "remove the old xcframework"
rm -fr OpenWebSDK.xcframework
ls -l
cp -r ../Release/OpenWebSDK.xcframework .
ls -l
PREVIOUS_SDK_VERSION=`cat OpenWebSDK.podspec | grep -m 1 s.version |  cut -d "=" -f2 | cut -d \" -f2 | cut -d \' -f2`
echo "OpenWebSDK.podspec - replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($RELEASE_VERSION)"
sed -i '' -e "s/${PREVIOUS_SDK_VERSION}/${RELEASE_VERSION}/g" OpenWebSDK.podspec
echo "OpenWebSDK.podspec - update source tag to $TAG"
sed -i '' -e "s/tag => s.version.to_s/tag => '${TAG}'/g" OpenWebSDK.podspec
git status
git add .
git status
git config credential.helper 'cache --timeout=120'
git config --global user.email "ios-dev@openweb.com"
git config --global user.name "OpenWeb Mobile bot via CircleCI"
git commit -m "CircleCI update OpenWebSDK.xcframework to tag $TAG"

git push origin "testing-integration-$TAG"
