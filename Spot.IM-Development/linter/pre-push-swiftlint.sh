#!/bin/sh

#  pre-push-swiftlint.sh
#  Spot-IM.Development
#
#  Created by Revital Pisman on 08/01/2023.
#  Copyright © 2023 Spot.IM. All rights reserved.

# hook script for swiftlint. It will triggered when you make a commit.

 LINT=$(which swiftlint)

 if [[ -e "${LINT}" ]]; then
     echo "SwiftLint Start..."
 else
     echo "SwiftLint does not exist, download from https://github.com/realm/SwiftLint"
     exit 1
 fi

 RESULT=$($LINT lint --quiet)

 if [ "$RESULT" == '' ]; then
     printf "\e[32mSwiftLint Finished.\e[39m\n"
 else
     echo ""
     printf "\e[41mSwiftLint Failed.\e[49m Please check below:\n"

     while read -r line; do

         FILEPATH=$(echo $line | cut -d : -f 1)
         L=$(echo $line | cut -d : -f 2)
         C=$(echo $line | cut -d : -f 3)
         TYPE=$(echo $line | cut -d : -f 4 | cut -c 2-)
         MESSAGE=$(echo $line | cut -d : -f 5 | cut -c 2-)
         DESCRIPTION=$(echo $line | cut -d : -f 6 | cut -c 2-)
         
 if [ "$TYPE" == 'error' ]; then
     printf "\n  \e[31m$TYPE\e[39m\n"
 else
     printf "\n  \e[33m$TYPE\e[39m\n"
 fi
 printf "    \e[90m$FILEPATH:$L:$C\e[39m\n"
 printf "    $MESSAGE - $DESCRIPTION\n"
     done <<< "$RESULT"

     printf "\nCOMMIT ABORTED. Please fix them before commiting.\n"
 
 #autocorrection
# git diff --cached --name-only | grep .swift | while read filename; do
#     /usr/local/bin/swiftlint autocorrect --path "$filename"
# done
#
# exit 1
# fi
