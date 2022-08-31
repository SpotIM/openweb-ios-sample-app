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

### ios beta

```sh
[bundle exec] fastlane ios beta
```

The setup_circle_ci fastlane action will perform the following actions:
  Create a new temporary keychain for use with match (see the CircleCI code signing doc for more details).
  Switch match to readonly mode to make sure CI does not create new code signing certificates or provisioning profiles.
  Set up log and test result paths to be easily collectible.

Push a new beta build to TestFlight

### ios unit_tests

```sh
[bundle exec] fastlane ios unit_tests
```



### ios release_pod

```sh
[bundle exec] fastlane ios release_pod
```



### ios build_release_sdk

```sh
[bundle exec] fastlane ios build_release_sdk
```



### ios prepare_demo_app

```sh
[bundle exec] fastlane ios prepare_demo_app
```



### ios release_demo_app

```sh
[bundle exec] fastlane ios release_demo_app
```



### ios release_public_demo_app

```sh
[bundle exec] fastlane ios release_public_demo_app
```



### ios bump_version

```sh
[bundle exec] fastlane ios bump_version
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
