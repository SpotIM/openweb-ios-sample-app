# This script should be run only after "create_light_rx_xcframeworks.sh" script
# Accept a version parm which will be the version in which the xcframeworks.zip(s) will be uploaded to github artifacts at "git@github.com:SpotIM/openweb-ios-vendor-frameworks.git"

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
RELEASE_TAG="Version ${RELEASE_VERSION}"

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
# Create a tag at "openweb-ios-vendor-frameworks.git" with the new zip xcframeworks
git clone git@github.com:SpotIM/openweb-ios-vendor-frameworks.git
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
git commit -m "Update RX xcframework.zip(s)to tag $RELEASE_TAG"
git tag $RELEASE_TAG
git push origin --tags


# TODO open PR instead
#git tag $RELEASE_VERSION
#git push origin master
#git push origin --tags

# 6 [TODO]
# Open a PR at [url] to update the checksums for the new zip xcframeworks
# checksum=$(getChecksum "$PROJECT_NAME" "$checksum")
