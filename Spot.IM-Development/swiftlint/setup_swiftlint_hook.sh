
# Create the hooks directory if it doesn't exist
HOOKS_DIR="../.git/hooks"
if [ ! -d "$HOOKS_DIR" ]; then
  mkdir "$HOOKS_DIR"
fi

# Copy the pre-push hook to the hooks directory
cp swiftlint/pre-push-swiftlint.sh "$HOOKS_DIR/pre-push"

# Make the pre-push hook executable
chmod +x "$HOOKS_DIR/pre-push"
 
