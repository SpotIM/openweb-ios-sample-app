# This script should be run only after "create_light_rx_xcframeworks.sh" script
# Accept a version parm which will be the version in which the xcframeworks.zip(s) will be uploaded to github "Assets" at "https://github.com/SpotIM/openweb-ios-vendor-frameworks"

# 1
# Set bash script to exit immediately if any commands fail.
set -e
set +u


# 2
# Setup some constants and functions for use later on.
SRCROOT=`pwd`
LIGHT_RX_XCFRAMEWORK_DIR="${SRCROOT}/Release/LightRxFrameworks"
PRODUCTS=(RxSwift RxRelay RxCocoa)
RX_SWIFT_CHECKSUM=``
RX_RELAY_CHECKSUM=``
RX_COCOA_CHECKSUM=``
git config credential.helper 'cache --timeout=120'
git config --global user.email "ios-dev@openweb.com"
git config --global user.name "OpenWeb Mobile bot"
RELEASE_VERSION=$1
RELEASE_TAG="Version-${RELEASE_VERSION}"
NEW_CHECKSUM_BRANCH="update-checksum-version-${RELEASE_VERSION}"

# Improtant: When using locally, you should provide `GITHUB_OPENWEB_USER_TOKEN` as in the CI environment
# Left blank here for security reasons
#GITHUB_OPENWEB_USER_TOKEN=""

setChecksum() {
    case $1 in
    "RxSwift")
    RX_SWIFT_CHECKSUM=$2;;
    "RxRelay")
    RX_RELAY_CHECKSUM=$2;;
    "RxCocoa")
    RX_COCOA_CHECKSUM=$2;;
    esac
}

getChecksum() {
    case $1 in
    "RxSwift")
    echo ${RX_SWIFT_CHECKSUM};;
    "RxRelay")
    echo ${RX_RELAY_CHECKSUM};;
    "RxCocoa")
    echo ${RX_COCOA_CHECKSUM};;
    esac
}


# 3
# Validate that "light" RX xcframeworks(s) exist at "Release/LightRxFrameworks" path
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"

    xcframeworkZipPath="${LIGHT_RX_XCFRAMEWORK_DIR}/${PROJECT_NAME}.xcframework.zip"
        if [ ! -e ${xcframeworkZipPath} ]; then
        echo "${PROJECT_NAME}.xcframework.zip is missing at ${LIGHT_RX_XCFRAMEWORK_DIR} path"
        echo "Failure to update RX light frameworks zip(s) in public repos - terminating script"
        exit 1
    fi
done


# 4
# Compute checksum for the zip XCFrameworks
cd ${LIGHT_RX_XCFRAMEWORK_DIR}
touch "Package.swift"
#swift package compute-checksum RxSwift.xcframework.zip
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"
    checksum=`swift package compute-checksum ${PROJECT_NAME}.xcframework.zip`
    printf "\nChecksum for binary ${PROJECT_NAME}.xcframework.zip is:\n${checksum}\n\n"
    setChecksum "$PROJECT_NAME" "$checksum"
done
rm "Package.swift"


# 5
# Create a tag at "openweb-ios-vendor-frameworks.git" with the new xcframeworks zips
# This tag will trigger a github action at "openweb-ios-vendor-frameworks.git", which will create a release with the xcframeworks zips files as part of the "Assets"
git clone git@github.com:SpotIM/openweb-ios-vendor-frameworks.git
cd ${LIGHT_RX_XCFRAMEWORK_DIR} # Just as a "bullet-proof" step
cd openweb-ios-vendor-frameworks/Vendor-Frameworks/
git checkout -b $RELEASE_TAG
echo "Trying to remove the old RX xcframework.zip(s)"
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"
    if [ -e ${PROJECT_NAME}.xcframework.zip ]; then
        rm -fr ${PROJECT_NAME}.xcframework.zip
        echo "Removed ${PROJECT_NAME}.xcframework.zip"
    fi
done
echo "Add the new RX xcframework.zip(s)"
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"
    cp -r ../../${PROJECT_NAME}.xcframework.zip ${PROJECT_NAME}.xcframework.zip
    echo "Added ${PROJECT_NAME}.xcframework.zip"
done
git status
git add .
git status
git commit -m "Update xcframework.zip(s) to version $RELEASE_VERSION"
git tag $RELEASE_TAG
git push origin --tags
# Cleanups
cd ${LIGHT_RX_XCFRAMEWORK_DIR}
rm -fr "openweb-ios-vendor-frameworks"


# 6
# Create a branch at git repo "https://github.com/SpotIM/openweb-ios-sdk-pod" with an updated checksum for each RX remote "*.xcframework.zip" file
cd ${LIGHT_RX_XCFRAMEWORK_DIR} # Just as a "bullet-proof" step
 git clone git@github.com:SpotIM/openweb-ios-sdk-pod.git
cd "openweb-ios-sdk-pod"
git checkout -b $NEW_CHECKSUM_BRANCH
VENDORS_VERSION_OLD="let version.*"
VENDORS_VERSION_NEW="let version = \"$RELEASE_VERSION\""

# Update the "version" in the Package.swift file
sed -i "" "s|$VENDORS_VERSION_OLD|$VENDORS_VERSION_NEW|g" Package.swift

# Update Rx xcframeworks checksum(s) in the Package.swift file
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"
    RX_MATCH="\"$PROJECT_NAME\":.*"
    tmpChecksum=$(getChecksum "$PROJECT_NAME")
    RX_CHECKSUM_REPLACMENT="\"$PROJECT_NAME\": \"$tmpChecksum\","
    if [ $PROJECT_NAME = "RxRelay" ]; then
    # ReRelay is the last element in the checksum mapper at "Package.swift" file, so remove the last ","
        RX_CHECKSUM_REPLACMENT=${RX_CHECKSUM_REPLACMENT%,}
    fi
    printf "checksum replacment for $PROJECT_NAME will be:\n$RX_CHECKSUM_REPLACMENT"
    sed -i "" "s|$RX_MATCH|$RX_CHECKSUM_REPLACMENT|g" Package.swift
done

git status
git add .
git status
git commit -m "Update checksum(s) to vendors xcframeworks version $RELEASE_VERSION"
git push --set-upstream origin $NEW_CHECKSUM_BRANCH


# 7
# Create a PR at git repo "https://github.com/SpotIM/openweb-ios-sdk-pod" for the branch we created above
generate_post_data()
{
  cat <<EOF
{
  "title": "Update checksum for release version $RELEASE_VERSION",
  "body": "Updated vendros xcframeworks checksum for release version $RELEASE_VERSION",
  "head": "$NEW_CHECKSUM_BRANCH",
  "base": "master"
}
EOF
}

curl -X POST \
  https://api.github.com/repos/SpotIM/openweb-ios-sdk-pod/pulls \
  -i -u "ios-dev-openweb:$GITHUB_OPENWEB_USER_TOKEN" \
  -H 'Accept: application/vnd.github.v3+json' \
  -d "$(generate_post_data)"

# Cleanups
cd ${LIGHT_RX_XCFRAMEWORK_DIR}
rm -fr "openweb-ios-sdk-pod"
