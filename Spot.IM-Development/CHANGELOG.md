# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2021-07-23

### Major Change

- Feature - New method `coordinator.showFullConversationViewController()` to open full conversation directly (instead of doing it from pre-conversation)
- Feature - Support setting of custom fonts on the widget by the publisher via `SpotIm.customFontFamiliy = "<font_family>"`
- Bug fix - Memory leak (see https://stackoverflow.com/a/43368507/583425)

## [1.1.0] - 2021-07-02

### Major Change

- Removed depedency of 'Google-Mobile-Ads-SDK' from SpotImCore. From now on publishers will pass an "AdsProvider" to the SDK and the only dependency on 'Google-Mobile-Ads-SDK' will be in the app target.


## [1.0.16] - 2021-20-01
### Fixed
- Error message translation - comment creation

### Internal
- Fix xCode preferences

## [1.0.15] - 2020-12-02
### Fixed
- Crash when scrolling conversation fast
- Crash on pull to refresh converstaion

### Removed
- Call to ab_test endpoint to avoid overloading the server for no reason, for now there are no active tests on iOS

## [1.0.14] - 2020-11-19
### Fixed
- Removed restricted dependency on Google-Ads-Sdk 7.67 so partners can update to later versions

## [1.0.13] - 2020-11-15
### Fixed
- Compatibility issue with swift 5.3.1

## [1.0.12] - 2020-11-08
### Added
- Translations for Arabic, Spanish and Portuguese
- x-openweb-token header logic to all requests to support UM 2.0

### Fixed
- Large gap above pre-conversation when there's no banner ad
- Core SDK compile script (generated no-ads frameworks)

### Changed
- Retry mechanism implementation (should prevent crashes)

## [1.0.11] - 2020-10-21
### Fixed
- 0 comments counter on Fox mobile app (Realtime not working due to post-id encoding)
- Realtime fetch memory leak
- Realtime not working on Fox mobile app
- Rank up/down counter disappear when user try to take action and the counter is larger than 1k
- Compatibility issue with swift 5.3

### Added
- Saving user data until it expired to reduce server load

## [1.0.10] - 2020-09-27
### Added
- dsym files to package to see stack trace when the SDK has a crash

## [1.0.9] - 2020-09-23
### Fixed
- Text written on the web with special chars showing html tags instead of chars on mobile

## [1.0.8] - 2020-08-24
### Changed
- Only call ab_test/ads/user if SDK is enabled in the main config
- Call user/data endpoint only when needed

## [1.0.7] - 2020-08-20
### Changed
- Google ads SDK to v7.64 for iOS 14 support

## [1.0.6] - 2020-08-14
### Changed
- Moved overrideUserInterfaceStyle from SPClientSettings to SpotIm for cleaner API

### Fixed
- Crash when sharign a comment on iPad

## [1.0.5] - 2020-08-09
### Changed
- Reduced network timeout interval from 60 seconds to 10 seconds [#123](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/123)

## [1.0.3] - 2020-06-29
### Added
- Updated Alamofire dependency to 5.0 [#121](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/121)
- engine-monetization-view event [#120](https://github.com/SpotIM/spotim-ios-sdk-demo-apps/pull/120)

## [1.0.2] - 2020-05-19
### Added
- New target type SpotImNoAds to support non-monetized partners (Fox)
- SSOStartResponse & SpotImConversationCounters now conforms to Codable protocol
- Article metadata is now taken from what sent into the  SpotImSDKFlowCoordinator.preConversationController API
- New brand OpenWeb is now under a feature flag and ready to be launched

## [1.0.1] - 2020-05-04
### Fixed
- getUserLoginStatus API

## [1.0.0] - 2020-03-24
### Added
- Error report when monetization ads fail to load
- LoginDelegate - A new and better way to trigger a login flow from the SDK to the parent app
  SpotIm.createSpotImFlowCoordinator(loginDelegate: LoginDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void))

### Fixed
- Floating 'post' button on create comment screen

### Deprecated
- SpotIm.createSpotImFlowCoordinator(navigationDelegate: SpotImSDKNavigationDelegate, completion: @escaping ((SpotImResult<SpotImSDKFlowCoordinator>) -> Void))

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
