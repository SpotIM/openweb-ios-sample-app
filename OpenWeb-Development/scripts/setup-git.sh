#!/bin/bash

# go to git root dir
cd "$(git rev-parse --show-toplevel)" || exit
git checkout develop

# Create the hooks directory if it doesn't exist
HOOKS_DIR=".git/hooks"
if [ ! -d "$HOOKS_DIR" ]; then
  mkdir "$HOOKS_DIR"
fi

# Copy hooks to the hooks directory
SOURCE_DIR=OpenWeb-Development/swiftlint
cp "$SOURCE_DIR/pre-push-swiftlint.sh" "$HOOKS_DIR/pre-push"
cp "$SOURCE_DIR/commit-msg.sh" "$HOOKS_DIR/commit-msg"

# Make hooks executable
chmod +x "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/commit-msg"

# Set up git blame ignore file
git config --local blame.ignoreRevsFile .git-blame-ignore-revs

# configure submodule
git submodule update --init --recursive
cd OpenWeb-Development/OpenWeb-SampleApp || exit
git checkout develop
git config --local blame.ignoreRevsFile .git-blame-ignore-revs
cd - || exit
