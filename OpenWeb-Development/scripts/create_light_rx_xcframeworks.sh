#https://stackoverflow.com/questions/35655698/how-to-archive-an-app-that-includes-a-custom-framework/35703033#35703033

# Merge Script

# 1
# Set bash script to exit immediately if any commands fail.
set -e
set +u


# 2
# Setup some constants and functions for use later on.
SRCROOT=`pwd`
VENDOR_FRAMEWORKS_DIR="${SRCROOT}/Vendor-Frameworks"
LIGHT_RX_XCFRAMEWORK_DIR="${SRCROOT}/Release/LightRxFrameworks"
PRODUCTS=(RxSwift RxRelay RxCocoa)
RX_SWIFT_CHECKSUM=``
RX_RELAY_CHECKSUM=``
RX_COCOA_CHECKSUM=``

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
# If remnants from a previous run exist, delete them.
if [ -d ${LIGHT_RX_XCFRAMEWORK_DIR} ]; then
rm -rf ${LIGHT_RX_XCFRAMEWORK_DIR}
fi
mkdir ${LIGHT_RX_XCFRAMEWORK_DIR}


# 4
# Create a "light" version of all RX dependencies as ".zip" of ".xcframework"s
# This is necessary for SPM.
# We shouldn't have the original RX ".xcframework"s in our project.
# Bring those temprarily from RX github repo, only when building a new "light" version of them
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"

    # Generate XCFramework (ios-arm64 and ios-arm64_x86_64-simulator architectures)
    xcodebuild -create-xcframework \
    -framework "${VENDOR_FRAMEWORKS_DIR}/${PROJECT_NAME}.xcframework/ios-arm64/${PROJECT_NAME}.framework" \
    -debug-symbols "${VENDOR_FRAMEWORKS_DIR}/${PROJECT_NAME}.xcframework/ios-arm64/dSYMs/${PROJECT_NAME}.framework.dSYM" \
    -framework "${VENDOR_FRAMEWORKS_DIR}/${PROJECT_NAME}.xcframework/ios-arm64_x86_64-simulator/${PROJECT_NAME}.framework" \
    -debug-symbols "${VENDOR_FRAMEWORKS_DIR}/${PROJECT_NAME}.xcframework/ios-arm64_x86_64-simulator/dSYMs/${PROJECT_NAME}.framework.dSYM" \
    -output "${LIGHT_RX_XCFRAMEWORK_DIR}/${PROJECT_NAME}.xcframework"

    # Code sign the binary
    codesign -v --sign "Spot.IM Ltd" "${LIGHT_RX_XCFRAMEWORK_DIR}/${PROJECT_NAME}.xcframework"
done

echo "Created light RX XCFrameworks... --> Done"


# 5
# Create zip binary files which includes the XCFrameworks
cd ${LIGHT_RX_XCFRAMEWORK_DIR}
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"

    # Create zip file which includes the XCFramework
    ditto -c -k --sequesterRsrc --keepParent ${PROJECT_NAME}.xcframework ${PROJECT_NAME}.xcframework.zip
done

echo "Created light zip RX XCFrameworks... --> Done"


# 6
# Compute checksum for the zip XCFrameworks
cd ${LIGHT_RX_XCFRAMEWORK_DIR} # Already in this folder, just bullet-proof if previous step removed
touch "Package.swift"
#swift package compute-checksum RxSwift.xcframework.zip
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"
    checksum=`swift package compute-checksum ${PROJECT_NAME}.xcframework.zip`
    printf "\nChecksum for binary ${PROJECT_NAME}.xcframework.zip is:\n${checksum}\n\n"
    setChecksum "$PROJECT_NAME" "$checksum"
done
rm "Package.swift"


# 7 [TODO]
# Open a PR at [url] to update the new zip xcframeworks
# checksum=$(getChecksum "$PROJECT_NAME" "$checksum")


# 8 [TODO]
# Open a PR at [url] to update the checksums for the new zip xcframeworks
