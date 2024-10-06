#!/bin/sh

#  xcode-swiftlint.sh
#  OpenWeb-Development
#
#  Created by Yonat Sharon on 2024-09-29.
#  Copyright © 2023 OpenWeb. All rights reserved.

# Show lint warnings in Xcode build tab

if [[ "Internal" != "${CONFIGURATION}" || $ENABLE_PREVIEWS == "YES" ]] ; then
   exit
fi

if test -d "/opt/homebrew/bin/"; then
    PATH="/opt/homebrew/bin/:${PATH}"
fi

SWIFTLINT_CONFIG="$SRCROOT/swiftlint/.swiftlint.yml"

# Check if the .swiftlint.yml file exists
if [ ! -f "$SWIFTLINT_CONFIG" ]; then
    echo "warning: $SWIFTLINT_CONFIG not found"
    exit
fi

if which swiftlint >/dev/null; then
    swiftlint lint --quiet "$1" --config "$SWIFTLINT_CONFIG"
else
    echo "warning: SwiftLint not installed."
fi
