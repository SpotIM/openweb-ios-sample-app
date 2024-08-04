#https://stackoverflow.com/questions/35655698/how-to-archive-an-app-that-includes-a-custom-framework/35703033#35703033

# Merge Script

# 1
# Set bash script to exit immediately if any commands fail.
set -e
set +u


# 2
# Setup some constants for use later on.
CONFIGURATION=$1
SRCROOT=`pwd`
WORKSPACE="OpenWeb-Development.xcworkspace"
TARGET_NAME="OpenWeb-SDK"
FRAMEWORK_NAME="OpenWebSDK"
BUILD_DIR="${SRCROOT}/build"
RELEASE_DIR="${SRCROOT}/Release/"


# 3
# If remnants from a previous build exist, delete them.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi

if [ -d "${SRCROOT}/Release" ]; then
rm -rf "${SRCROOT}/Release"
fi

mkdir "${SRCROOT}/Release"


# 4
# Build the framework for device and for simulator (using
# all needed architectures).
xcodebuild archive -workspace "${WORKSPACE}" -scheme "${TARGET_NAME}" -configuration "${CONFIGURATION}" -destination="iOS" -sdk iphonesimulator SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -archivePath "${BUILD_DIR}/Release-iphonesimulator"
xcodebuild archive -workspace "${WORKSPACE}" -scheme "${TARGET_NAME}" -configuration "${CONFIGURATION}" -destination="iOS" -sdk iphoneos        SKIP_INSTALL=NO SWIFT_SERIALIZE_DEBUGGING_OPTIONS=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES -archivePath "${BUILD_DIR}/Release-iphoneos"


ls -l "${BUILD_DIR}/"


# 5
echo "Creating XCFramework..."

# XCFramework with debug symbols - see https://pspdfkit.com/blog/2021/advances-in-xcframeworks/#built-in-support-for-bcsymbolmaps-and-dsyms
xcodebuild -create-xcframework \
    -framework "${SRCROOT}/build/Release-iphoneos.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -debug-symbols "${SRCROOT}/build/Release-iphoneos.xcarchive/dSYMs/${FRAMEWORK_NAME}.framework.dSYM" \
    -framework "${SRCROOT}/build/Release-iphonesimulator.xcarchive/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework" \
    -debug-symbols "${SRCROOT}/build/Release-iphonesimulator.xcarchive/dSYMs/${FRAMEWORK_NAME}.framework.dSYM" \
    -output "${RELEASE_DIR}/${FRAMEWORK_NAME}.xcframework"

# Sign OpenWebSDK .xcframework
# Keeping this part to sign .xcframework when creating locally, however we sign it with "match" tool at the fastlane script
# codesign -v --sign "Spot.IM Ltd" "${RELEASE_DIR}/OpenWebSDK.xcframework"

echo "Creating XCFramework... --> Done"


# 6
# Delete the most recent build.
if [ -d "${SRCROOT}/build" ]; then
rm -rf "${SRCROOT}/build"
fi
