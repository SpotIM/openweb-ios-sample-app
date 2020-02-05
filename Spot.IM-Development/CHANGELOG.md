# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.31] - 2020-02-05
### Fixed
- Pre-conversation does not update after adding/deleting a comment in main conversation and going back
- Calling conversation/async with a url parameter that got escaped slashes
- Create comment screen layout for small size screen
- Create comment screen layout for iOS 10

## [0.0.30] - 2020-02-03
### Added
- Getting AB test configuration from a new endpoint [#91](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/91)
- Don't request an ad from DFP if the user is not in a test group that should see this ad [#91](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/91)
- Send split_name property for all events to better monitor AB test groups [#92](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/92)

### Fixed
- Pre-conversation always changes the sorting back to .best [#93](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/93)
