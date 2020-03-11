# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.36] - 2020-03-11
### Added
- Support for more banner ad sizes

### Changed
- Placement of the pre-conversation ad. From bottom to top of the UI

### Fixed
- Sticky banner in main conversation not showing

## [0.0.35] - 2020-03-04
### Changed
- UITextField to UITextView in comment creation screen to resolve focusing issue with Channel 7

## [0.0.34] - 2020-02-20
### Fixed
- Layout warnings on comment creation screen

## [0.0.33] - 2020-02-18
### Added
- IDFA for all monetization events
- Create comment screen shows loader when SSO is in progress
- Support for disabling interstitial for logged in user depending on publisher configuration

### Fixed
- Pre-conversation memory leak
- Main conversation table bounces when there is a small amount of comments
- First comment does not appear after posting
- First comment does not have username/avatar after posting

### Changed
- DFP custom target

## [0.0.32] - 2020-02-06
### Added
- Better API logger with only important info

### Fixed
- Calling conversation/async with a x-post-id=default instead of real post-id
- Some events that a conversation related called with x-post-id=default

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
