# CircleCI Usage

## Introduction

We integrate our code with CircleCI so that every `git push` will trigger a build.


We currently support 2 types of "workflows":

1. independent_job_workflow - a workflow to trigget each job independently 

2. release_multi_workflow - build the SDK XCFramework on multiple Xcode versions. Basically trigger `release_sdk_job` and multiple `release_tag_job` for different Xcode versions. Triggered by any branch that matches `/^release/multi/.*/` for example `release/multi/4.2.8`


We currently support 5 types of "jobs":

1. default_job - build the app scheme and run unit-tests on the SDK. Triggered by any branch that DOES NOT match `/^release/.*/`

2. release_sdk_job - build the SDK XCFramework and release a new version for the SDK. Triggered by any branch that matches `/^release/sdk/.*/` for example `release/sdk/4.2.8`

3. release_tag_job - build the SDK XCFramework on Xcode 12.5 and create a tag in the pod repository with the SDK. Triggered by any branch that matches `/^release/tag12.5/.*/` for example `release/tag12.5/4.2.8`

4. release_app_job - build the Sample App and release a new version to Test-Flight. Triggered by any branch that matches `/^release/app/.*/` for example `release/app/4.2.8`

4. release_public_app_job - build the Sample App for public mode and release a new version to Test-Flight. Triggered by any branch that matches `/^release/public_app/.*/` for example `release/public_app/4.2.8`


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


## release_app_job

1. Bump the "build number".

2. Clean and build the Sample App.

3. Release the sample app - upload to Test Flight and automatically notify internal testers.


## release_public_app_job

1. Same as release_app_job but with a public preset and designed to be shared with publishers for testing and etc.


## release_multi_workflow

1. grep the version from the branch name.

2. Trigger `release_sdk_job` with that version.

3. Trigger multiple `release_tag_job` from a preset of Xcode versions.
