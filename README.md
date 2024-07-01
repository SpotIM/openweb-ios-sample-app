# openweb-ios-sdk-demo-apps
In this repository:
* Development SDK for our publishers and clients
* Demo app for testing the SDK

## Scheme - OpenWeb-SampleApp
This project is for OpenWeb iOS Demo App and SDK development.

### How to run OpenWeb-SampleApp:
1. OpenWebSDK is embeded framework in OpenWeb-SampleApp target
2. Install pods in the OpenWeb-Development folder
3. Open the workspace (not the project)
4. Run OpenWeb-SampleApp target.

## Scheme - OpenWeb-PublicSampleApp
This project is for OpenWeb iOS Demo App and SDK development with a public preset.

## Scheme - OpenWeb-BetaSampleApp
Used for testing beta stuff.

## Scheme - OpenWebSDK
This is only to compile OpenWeb iOS SDK.

## How to release an SDK version
1. branch out from master and name the branch as in this scheme:
   release/sdk/<version number>
   for example if the version is 1.16.1: release/sdk/1.16.1
2. push the branch to origin and the CI will release the SDK version
    
## How to release an SDK tag version
1. branch out from master and name the branch as in this scheme:
   release/tag<tag number>/<version number>
   for example if the tag number is 14.1.0 and the version is 1.16.1: release/tag14.1.0/1.16.1
2. push the branch to origin and the CI will release the SDK tag version

## Demo Apps for testing integration methods of the SDK:

### Demo app using CocoaPods
Link to the demo app using CocoaPods:

https://github.com/SpotIM/iOS-SDK-Test-Cocoapods-Integration

For more information check out the readme in this link
Download the demo app from this link or Clone using your git app

### Demo app using SPM
Link to the demo app using SPM:

https://github.com/SpotIM/iOS-SDK-Test-SPM-Integration

For more information check out the readme in this link
Download the demo app from this link or Clone using your git app

## Integrating the iOS SDK using CocoaPods or SPM:

### How to integrate OpenWeb iOS SDK to a project via CocoaPods:
1. Add Spot.IM spec repo to your system by running the following command in Terminal:  
  `pod repo add OpenWebSDK.Spec git@github.com:SpotIM/openweb-ios-sdk-pod.git`
2. Add spec sources at the top of the podfile:  
  `source 'git@github.com:SpotIM/openweb-ios-sdk-pod.git'`  
  `source 'https://github.com/CocoaPods/Specs.git'`  
3. Set dependency as follows: `pod 'OpenWebSDK'`
4. Run the following command in Terminal:  
  `pod repo update OpenWebSDK.Spec`
4. Run the following command to make sure the framework is available via CocoaPods:  
  `pod search OpenWebSDK`  
5. Run pod install
6. Open workspace file and run

### How to integrate OpenWeb iOS SDK to a project via SPM:
1. Right click your project's target and choose add packages.
2. Enter the package link into the search

   https://github.com/SpotIM/openweb-ios-sdk-pod

3. Choose the OpenWeb package and tap Add package, let it install.

## Create mock articles data - for publishers with OpenWeb on web
1. Open the publishers website
2. Go into an article that contains OpenWeb conversation
3. Copy the link as the URL
4. Paste this link back into the converstaion and inspect the web page (filter /extract)
5. In the response to /extract you can find a json object with all the article data
