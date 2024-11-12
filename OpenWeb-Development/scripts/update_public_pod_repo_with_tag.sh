#!/bin/bash

RELEASE_VERSION=$1
XCODE_VERSION=$2
TAG="$RELEASE_VERSION-xcode$XCODE_VERSION"

git clone git@github.com:SpotIM/openweb-ios-sdk-pod.git
cd openweb-ios-sdk-pod
git checkout -b $TAG
echo "remove the old xcframework"
rm -fr OpenWebSDK.xcframework
ls -l
cp -r ../Release/OpenWebSDK.xcframework .
ls -l

PREVIOUS_SDK_VERSION=`cat OpenWebSDK.podspec | grep -m 1 s.version |  cut -d "=" -f2 | cut -d \" -f2 | cut -d \' -f2`
echo "OpenWebSDK.podspec - replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($RELEASE_VERSION)"
sed -i '' -e "/s.version *= /s/'${PREVIOUS_SDK_VERSION}'/'${RELEASE_VERSION}'/" OpenWebSDK.podspec
echo "OpenWebSDK.podspec - update source tag to $TAG"
sed -i '' -e "s/tag => s.version.to_s/tag => '${TAG}'/g" OpenWebSDK.podspec

echo "OpenWebSDK.podspec - update OpenWebSDKAdapter dependency to use tag - $TAG"
sed -i '' -e "/s.dependency 'OpenWebSDKAdapter'/s|,.*|, :git => 'https://github.com/SpotIM/openweb-ios-sdk-pod.git', :tag => '${TAG}'|" OpenWebSDK.podspec

echo "OpenWebSDKAdapter.podspec - replacing previous version ($PREVIOUS_SDK_VERSION) with current version ($RELEASE_VERSION)"
sed -i '' -e "/s.version *= /s/'${PREVIOUS_SDK_VERSION}'/'${RELEASE_VERSION}'/" OpenWebSDKAdapter.podspec
echo "OpenWebSDKAdapter.podspec - update source tag to $TAG"
sed -i '' -e "s/tag => s.version.to_s/tag => '${TAG}'/g" OpenWebSDKAdapter.podspec

echo "Update OpenWebSDKAdapter files"
if [ -d "OpenWebSDKAdapter" ]; then
rm -rf "OpenWebSDKAdapter"
fi
cp -r ../OpenWeb-Development/OpenWeb-SDKAdapter OpenWebSDKAdapter

git status
git add .
git status
git config credential.helper 'cache --timeout=120'
git config --global user.email "ios-dev@openweb.com"
git config --global user.name "OpenWeb Mobile bot via CircleCI"
git commit -m "CircleCI update OpenWebSDK.xcframework to tag $TAG"

git tag $TAG
git push origin --tags
