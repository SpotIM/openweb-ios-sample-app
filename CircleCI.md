# CircleCI Usage

## Introduction

We integrate our code with CircleCI so that every `git push` will trigger a build. 

We currently support 3 types of "jobs", very soon we will support 4 types

1. default_job - build the app scheme and run unit-tests on the SDK. Triggered by any branch that DOES NOT match `/^release/.*/`

2. release_sdk_job - build the SDK XCFramework and release a new version for the SDK. Triggered by any branch that matches `/^release/sdk/.*/` for example `release/sdk/4.2.8`

3. release_tag_job - build the SDK XCFramework on Xcode 12.5 and create a tag in the pod repository with the SDK. Triggered by any branch that matches `/^release/tag12.5/.*/` for example `release/tag12.5/4.2.8`

4. release_app_job - build the Sample App and release a new version to Test-Flight. Triggered by any branch that matches `/^release/app/.*/` for example `release/app/4.2.8`


## default_job

build the app scheme and run unit-tests on the SDK. If one of those fail the job fail.

## release_sdk_job

1. grep the version from the branch name.

2. Update version according to (1) and bump the "build number".

3. clean and build the SDK XCFramework

4. Update Github repo (commit, push, git tag) with new SDK version.

5. Create a pull request on Github for the new release (in the source code repo).

6. Update public Github repo SpotIM/spotim-ios-sdk-pod with new SDK version

## release_tag_job

1. grep the version from the branch name.

2. clean and build the SDK XCFramework on Xcode 12.5.

3. Update public Github repo SpotIM/spotim-ios-sdk-pod with new SDK tag.


## release_app_job (TBD)

1. grep the version from the branch name.

2. Update version according to (1) and bump the "build number".

3. Clean and build the Sample App. SpotImCore SDK will be taken from Podfile dependency with version as in (1).

4. Release the sample app - upload to Test Flight and automatically notify internal testers.


