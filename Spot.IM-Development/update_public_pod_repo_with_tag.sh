#!/bin/bash

RELEASE_VERSION=$1
TAG="$RELEASE_VERSION-xcode12.5"

git clone git@github.com:SpotIM/spotim-ios-sdk-pod.git
git checkout -b $TAG
cd spotim-ios-sdk-pod
echo "remove the old xcframework"
rm -fr SpotImCore.xcframework
ls -l
cp -r ../Release/SpotImCore.xcframework .
ls -l
PREVIOUS_SDK_VERSION=`cat SpotIMCore.podspec | grep -m 1 s.version |  cut -d "=" -f2 | cut -d \" -f2 | cut -d \' -f2`
echo "SpotIMCore.podspec - replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($RELEASE_VERSION)"
sed -i '' -e "s/${PREVIOUS_SDK_VERSION}/${RELEASE_VERSION}/g" SpotImCore.podspec
echo "SpotIMCore.podspec - update source tag to $TAG"
sed -i '' -e "s/:tag => '${RELEASE_VERSION}'/:tag => '${TAG}'/g" SpotImCore.podspec
git status
git add .
git status
git config credential.helper 'cache --timeout=120'
git config --global user.email "odedre@gmail.com"
git config --global user.name "Oded Regev via CircleCI"
git commit -m "CircleCI update SpotIMCore.xcframework to tag $TAG"

git tag $TAG
git push origin --tags
