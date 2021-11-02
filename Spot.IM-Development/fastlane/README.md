fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios beta
```
fastlane ios beta
```
The setup_circle_ci fastlane action will perform the following actions:
  Create a new temporary keychain for use with match (see the CircleCI code signing doc for more details).
  Switch match to readonly mode to make sure CI does not create new code signing certificates or provisioning profiles.
  Set up log and test result paths to be easily collectible.

Push a new beta build to TestFlight
### ios unit_tests
```
fastlane ios unit_tests
```

### ios release_pod
```
fastlane ios release_pod
```

### ios build_release_sdk
```
fastlane ios build_release_sdk
```

### ios prepare_demo_app
```
fastlane ios prepare_demo_app
```

### ios bump_version
```
fastlane ios bump_version
```


----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
