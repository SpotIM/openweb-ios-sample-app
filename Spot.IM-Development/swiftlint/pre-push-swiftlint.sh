#!/bin/sh

#  pre-push-swiftlint.sh
#  Spot-IM.Development
#
#  Created by Revital Pisman on 08/01/2023.
#  Copyright © 2023 Spot.IM. All rights reserved.

# hook script for swiftlint. It will triggered when you make a push.

# Check if swiftlint is installed
command -v swiftlint >/dev/null 2>&1 || { echo >&2 "SwiftLint is not installed. Aborting pre-push hook."; exit 1; }

# Print message indicating that swiftlint check has started
echo "Starting swiftlint check..."

# Run swiftlint
OUTPUT=$(swiftlint)

# Check if swiftlint found any warnings or errors
if [[ $OUTPUT == *"warning:"* || $OUTPUT == *"error:"* ]]; then
    echo "SwiftLint found warnings or errors:"
    echo "$OUTPUT"
    echo "Aborting pre-push-swiftlint hook."
    exit 1
else
    echo "SwiftLint check succeeded"
fi
