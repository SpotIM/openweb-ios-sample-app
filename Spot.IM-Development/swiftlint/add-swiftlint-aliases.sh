#!/bin/bash

# Define the aliases
ALIAS_LINT="alias sLint='swiftlint lint --config swiftlint/.swiftlint.yml --reporter xcode'"
ALIAS_FIX="alias sFix='swiftlint --fix --config swiftlint/.swiftlint.yml --reporter xcode'"

# Define the shell configuration files to modify
CONFIG_FILES=(
  ~/.bashrc
  ~/.bash_profile
  ~/.zshrc
  ~/.zprofile
)

# Add the lint alias to each configuration file
for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$file" ]; then
    if grep -q "$ALIAS_LINT" "$file"; then
      echo "sLint alias already exists in $file."
    else
      sudo echo "$ALIAS_LINT" >> "$file"
      echo "sLint lint alias added to $file."
    fi
  fi
done

# Add the fix alias to each configuration file
for file in "${CONFIG_FILES[@]}"; do
  if [ -f "$file" ]; then
    if grep -q "$ALIAS_FIX" "$file"; then
      echo "sFix alias already exists in $file."
    else
      sudo echo "$ALIAS_FIX" >> "$file"
      echo "sFix alias added to $file."
    fi
  fi
done

# Restart the terminal for changes to take effect
echo "Please restart the terminal for the changes to take effect."
