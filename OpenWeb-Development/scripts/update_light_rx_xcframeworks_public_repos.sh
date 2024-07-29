# This script should be run only after "create_light_rx_xcframeworks.sh" script

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


# 4 [TODO]
# Open a PR at [url] to update the new zip xcframeworks


# 5 [TODO]
# Open a PR at [url] to update the checksums for the new zip xcframeworks
# checksum=$(getChecksum "$PROJECT_NAME" "$checksum")
