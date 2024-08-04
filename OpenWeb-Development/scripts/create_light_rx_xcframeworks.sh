# Original RX xcframeworks(s) should be placed at "/Vendor-Frameworks" path in order for this script to run properly

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


# 3
# If remnants from a previous run exist, delete them.
if [ -d ${LIGHT_RX_XCFRAMEWORK_DIR} ]; then
rm -rf ${LIGHT_RX_XCFRAMEWORK_DIR}
fi
mkdir ${LIGHT_RX_XCFRAMEWORK_DIR}


# 4
# Validate that original RX xcframeworks(s) exist at "/Vendor-Frameworks" path
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"

    xcframeworkPath="${VENDOR_FRAMEWORKS_DIR}/${PROJECT_NAME}.xcframework"
        if [ ! -e ${xcframeworkPath} ]; then
        rm -rf ${LIGHT_RX_XCFRAMEWORK_DIR}
        echo "${PROJECT_NAME}.xcframework is missing at ${VENDOR_FRAMEWORKS_DIR} path"
        echo "Failure to create RX frameworks - terminating script"
        exit 1
    fi
done


# 5
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


# 6
# Create zip binary files which includes the XCFrameworks
cd ${LIGHT_RX_XCFRAMEWORK_DIR}
for product in ${PRODUCTS[@]}; do
    PROJECT_NAME="$product"

    # Create zip file which includes the XCFramework
    ditto -c -k --sequesterRsrc --keepParent ${PROJECT_NAME}.xcframework ${PROJECT_NAME}.xcframework.zip
done

echo "Created light zip RX XCFrameworks... --> Done"
