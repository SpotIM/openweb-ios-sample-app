#!/bin/bash

COMMIT_MSG_FILE=$1
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# Extract the Jira ticket from the branch name
if [[ $BRANCH_NAME =~ ([A-Z]{2,9}-[0-9]+) ]]; then
    TICKET=${BASH_REMATCH[1]}
else
    echo "Warning: Jira ticket missing in branch name $BRANCH_NAME"
    exit 0
fi

# Check if the commit message already contains the ticket
if grep -q "$TICKET" "$COMMIT_MSG_FILE"; then
    exit 0
fi

# Prepend the ticket to the commit message
echo "$TICKET $(cat "$COMMIT_MSG_FILE")" > "$COMMIT_MSG_FILE"
