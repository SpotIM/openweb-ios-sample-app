#!/bin/sh

#  pre-push-swiftlint.sh
#  Spot-IM.Development
#
#  Created by Revital Pisman on 08/01/2023.
#  Copyright © 2023 Spot.IM. All rights reserved.

# hook script for swiftlint. It will triggered when you make a push.

if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin/:${PATH}"
fi

export PATH

# Set the path to the .swiftlint.yml config file
SWIFTLINT_CONFIG="Spot.IM-Development/swiftlint/.swiftlint.yml"

# Check if the .swiftlint.yml file exists
if [ -f $SWIFTLINT_CONFIG ]; then
    # Check if swiftlint is installed
    if which swiftlint >/dev/null; then
        echo "SwiftLint check started..."
        # Run swiftlint lint command with the specified config file
        if swiftlint lint --strict --config $SWIFTLINT_CONFIG; then
            echo "SwiftLint check succeeded"
        else
            echo "SwiftLint check failed, please fix the warnings and errors"
            exit 1
        fi
    else
        echo "warning: SwiftLint not installed."
    fi
else
    # If the .swiftlint.yml file is missing, print an error message
    echo "error: $SWIFTLINT_CONFIG not found"
    exit 1
fi
