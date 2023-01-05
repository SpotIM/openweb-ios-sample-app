fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```

The setup_circle_ci fastlane action will perform the following actions:
  Create a new temporary keychain for use with match (see the CircleCI code signing doc for more details).
  Switch match to readonly mode to make sure CI does not create new code signing certificates or provisioning profiles.
  Set up log and test result paths to be easily collectible.

Run unit tests

### ios build_development_ipa

```sh
[bundle exec] fastlane ios build_development_ipa
```

Build development ipa

### ios build_release_sdk

```sh
[bundle exec] fastlane ios build_release_sdk
```

Build a release version of the SDK

### ios release_demo_app

```sh
[bundle exec] fastlane ios release_demo_app
```

Release Sample App (internal preset)

### ios release_beta_demo_app

```sh
[bundle exec] fastlane ios release_beta_demo_app
```

Release Sample App (beta preset)

### ios release_public_demo_app

```sh
[bundle exec] fastlane ios release_public_demo_app
```

Release Sample App (public preset)

### ios set_version

```sh
[bundle exec] fastlane ios set_version
```

Set version in xcode target and project plists

### ios increment_build_in_range

```sh
[bundle exec] fastlane ios increment_build_in_range
```

Increment build if it is in range, or set build to lower end

### ios set_build

```sh
[bundle exec] fastlane ios set_build
```

Set build to specific number

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
