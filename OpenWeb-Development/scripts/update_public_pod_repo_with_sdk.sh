#!/bin/bash

RELEASE_VERSION=$1

git clone git@github.com:SpotIM/openweb-ios-sdk-pod.git
cd openweb-ios-sdk-pod
echo "remove the old xcframework"
rm -fr OpenWebSDK.xcframework
ls -l
cp -r ../Release/OpenWebSDK.xcframework .
ls -l
PREVIOUS_SDK_VERSION=`cat OpenWebSDK.podspec | grep -m 1 s.version |  cut -d "=" -f2 | cut -d \" -f2 | cut -d \' -f2`
echo "OpenWebSDK.podspec - replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($RELEASE_VERSION)"
sed -i '' -e "s/${PREVIOUS_SDK_VERSION}/${RELEASE_VERSION}/g" OpenWebSDK.podspec
PREVIOUS_SDK_VERSION_IN_README=`cat README.md | grep pod\ \'OpenWebSDK\' | cut -d , -f2 | cut -d \' -f2`
echo "README.md - replacing previous version ($PREVIOUS_SDK_VERSION_IN_README) with current version ($RELEASE_VERSION)"
sed -i '' -e "s/${PREVIOUS_SDK_VERSION_IN_README}/${RELEASE_VERSION}/g" README.md
git status
git add .
git status
git config credential.helper 'cache --timeout=120'
git config --global user.email "ios-dev@openweb.com"
git config --global user.name "OpenWeb Mobile bot via CircleCI"
git commit -m "CircleCI update OpenWebSDK.xcframework to version $RELEASE_VERSION"

git tag $RELEASE_VERSION
git push origin master
git push origin --tags


