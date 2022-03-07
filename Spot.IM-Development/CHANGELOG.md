# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.9.2] - 2022-03-06
### Fixed
- Framework integration with cocoapods

## [1.9.2] - 2022-03-03
### Added
- Buttons customization

### Fixed
- Edit message should not be saved on cache
- Reply screen UI is not aligned well
- Real time counter does not start in conversation screen

### Internal
- Infra - Building UI with chaining
- Infra - SnapKit like capabilities to work with UI
- Infra - Register UITableViewCell easily

## [1.9.0] - 2022-01-13
### Added
- Create comment with image
- Edit comment

## [1.8.0] - 2022-01-02
### Added
- Real time viewing counter
- New guest nickname design
- Support M1 Apple chips

### Internal
- RxSwift and RxCocoa integration

## [1.7.0] - 2021-12-14
### Added
- Staff badges
- Update Alamofire dependency to version 5.4

### Fixed
- Comment label buttons are not clickable
- Conversation counters replies and comments access level

### Changed
- Refactor create comment/reply vc and model

## [1.6.9] - 2021-11-25
### Fixed
- Crash when trying to open a mailto link
- Tableview invalid update crash
- Constraints warnings

### Changed
- Empty comments title (renaming)

## [1.6.8] - 2021-11-01
### Added
- Present full conversation completion handler
- Push full conversation completion handler

### Fixed
- Duplicated comment labels
- Remove expired user token from authorization header when fetching user/data

## [1.6.7] - 2021-10-28
### Fixed
- Upvote/Downvote remains highlight even if user cancels SSO
- Flag for RN issue with reply to comment

## [1.6.6] - 2021-10-25
### Fixed
- Fix crash when fail to encode comment html text

### Changed
- Error handling improvements

## [1.6.5] - 2021-10-14

### Added
- Add flag for RN - show login screen on root VC

### Fixed
- Fix reloading conversation TableView when view did layout subviews

### Changed
- Refactor create comment screen footer view

## [1.6.4] - 2021-10-04

### Added
- Handle window size changes to support iPad split view

### Fixed
- New comment creation screen title should not be editable

## [1.6.3] - 2021-09-30

### Changed
- Build SDK in Xcode 13
- Flag for enable customization of navigation title

### Fixed
- Empty conversation image size

## [1.6.2] - 2021-09-27

### Changed
- Update GoogleAdsProvider files
- Make SPEventInfo Codable

## [1.6.1] - 2021-09-23

### Added
- Support for Swift Package Manager

### Fixed
- Commenting on empty conversation in read only should be disable

## [1.6.0] - 2021-09-14

### Added
- Support GoogleAdsSDK V8 (breaking changes)
- Button only in pre-conversation
- Full conversation ad banner
- Read only conversation

## [1.5.13] - 2021-08-19

### Fixed
- Replies cannot be viewed after refreshing the page
- Analytics events fixes
- Big ads are cut in pre-conversation

## [1.5.12] - 2021-08-05

### Fixed
- Any transition from pre-conv to full should show the interstitial (if its enabled)

### Changed
- Event listener refactor - Add more events and not send all of them to BI
- When the full conversation is opened by the publisher send "viewed" event instead of "main-viewed"

## [1.5.11] - 2021-07-28

### Added
- Fix for XCFramework build setting - `CLANG_ENABLE_CODE_COVERAGE=NO` - see https://blog.scichart.com/xcframework-xcode-12-and-bigsur-issues/

## [1.5.10] - 2021-07-21

### Added
- Analytics event listener

### Fixed
- “Add a comment” screen gets locked in Portrait mode

## [1.5.9] - 2021-07-15

### Added
- Comment creation landscape support

### Fixed
- Nav bar title is editable
- Comment counter is not visible in landscape
- Posting a reply doesn’t increase comment counter
- Reported comment reappears

## [1.5.8] - 2021-07-08

### Added
- Support display image in conversation
- Publisher custom BI data

### Fixed
- Footer is cropped on empty conversation

## [1.5.7] - 2021-06-29

### Fixed
- Toolbar overlaps conversation footer
- Conversation navigation bar is not updated when dark mode change on comment creation screen
- New create comment screen title “Add a Comment” should be stylized as “Add a comment”

### Changed
- Comment creation screen orientation should be portrait for iPhone (on present conversation ViewController)

## [1.5.6] - 2021-06-23

### Added
- Create comment screen new design (with flag)
- "Sort by" new design
- "Sort by" option text customization
- Navigation title customization
- Conversation footer customization
- Community guidelines text customization

### Changed
- Update divider UI in Conversation

## [1.5.5] - 2021-06-10

### Added
- Community question
- Community question - support customization
- SayCtrl - support customization
- Success callback on SDK initialization

### Fixed
- Back icon for dark-mode
- Login prompt above sticky header
- Empty view update when switching dark/light mode

### Changed
- Use one time token for the websdk
- Login prompt customization via SpotImCustomUIDelegate
- Signup To Post button (Comment Create) always enabled

## [1.5.4] - 2021-05-25

### Fixed
- Enlarge back button hit area
- Content description for talkback accessibility
- Crash with empty conversation without header

## [1.5.3] - 2021-05-13

### Added
- Support dark mode in websdk
- Display Gif in comment
- Placeholder for empty full conversation

### Changed
- Block start/complete SSO if user is already logged-in
- Remove idfa usages from SDK


## [1.5.2] - 2021-05-5
### Infra

- Build SDK with Xcode v12.5 (iOS 14.5)


## [1.5.1] - 2021-04-29

### Added
- Clicking on my guest profile should open registration flow

### Fixed
- Deleted message should not show comment labels
- The icon change its color when clicking on the context-menu
- Dark mode change should affect nav bar

## [1.5.0] - 2021-04-28

### Added
- Comment Labels
- NYPost login prompt

### Fixed
- Switch dark/light mode in full conversation screen
- Links in comment should open in Safari view controller


## [1.4.4] - 2021-04-07

### Fixed
- Toggle Like/Dislike persistent
- PreConversationViewController height calculation
- Community guideline too close to the top when presenting full conversation


## [1.4.3] - 2021-03-30

### Added
- Profile page
- Community guidelines

### Fixed
- Description on comment screen when header is hided
- Nav bar when conversation view controller is pushed

## [1.4.2] - 2021-03-23

### Changes

- Feature - new `getUserLoginStatusWithId()` method which returns the "user id" together with the status.
- Feature - new `getRegisteredUserId()` method which returns the "user id"
- Feature - new property `displayArticleHeader` to allow publisher to control wheter article header should be displayed (on top of conversation)
- Feature - new SSO login `SpotImLoginDelegate` method `func presentControllerForSSOFlow(with spotNavController: UIViewController)`

## [1.4.1] - 2021-03-18

### Changes

- Bug fix - On pre-conversation banner ad appeared twice (added a cleanup before reload).

## [1.4.0] - 2021-03-16

### Major Change

- Open Full Conversation - SDK exposes 2 new methods to open full-conversation VC directly from the Article Screen (without pre-conversation). Example code:
`coordinator.presentFullConversationViewController(inViewController: self, withPostId: self.postId, articleMetadata: self.metadata, selectedCommentId: nil)`

- Fix - user action Like\Dislike - guest not allowed to rank, first the user must login.

- Fix - Article header in the widget - if the image is missing don't leave space.

- Internal - Switch to new PITC endpoint that sample app uses #157

- Internal - Add 3 options for SSO login (pre-con, push full, present full)



## [1.3.0] - 2021-03-03

### Major Change

- XCFramework support - starting this version SDK will be delivered as XCFramework (all iOS frameworks should be distributed as XCFramework according to Apple - see https://developer.apple.com/videos/play/wwdc2019/416/)

- Fix - `use_mudalar_headers!` setting in Podfile didn't work

- Feature - Disable monetization for subscribers according to server setting.


## [1.2.0] - 2021-02-23

### Major Change

- Feature - New method `coordinator.showFullConversationViewController()` to open full conversation directly (instead of doing it from pre-conversation)
- Feature - Support setting of custom fonts on the widget by the publisher via `SpotIm.customFontFamiliy = "<font_family>"`
- Bug fix - Memory leak (see https://stackoverflow.com/a/43368507/583425)

## [1.1.0] - 2021-02-07

### Major Change

- Removed depedency of 'Google-Mobile-Ads-SDK' from SpotImCore. From now on publishers will pass an "AdsProvider" to the SDK and the only dependency on 'Google-Mobile-Ads-SDK' will be in the app target.


## [1.0.16] - 2021-01-20
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
