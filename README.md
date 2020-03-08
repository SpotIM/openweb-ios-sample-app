# spotim-ios-sdk-demo-apps
In this repository:
* Development app for developing Spot.IM SDK
* Demo apps for testing the SDK

## Spot.IM-Development
This project is for Spot.IM iOS SDK development.

#### To run Spot.IM-Development:
1. SpotImSDK is embeded framework in Spot.IM-Developmen project
2. Install pods in the Spot.IM-Development folder
3. Open the workspace, not the project
4. Run Spot-IM.Development target for app without monetization or  Spot-IM.DevelopmentWithAds one for app with 
monetization

## Spot.IM-Example.DND
**This approach is unavailable right now because of `Alamofire` cocoapod dependency**

This is an example of a project that uses Spot.IM iOS SDK binary (.framework) via **drag'n'drop**.

#### To run Spot.IM-Example.DND:
It just works, run Spot.IM-Example.DND.xcodeproj.

#### To start using, replace or update the framework in a project
1. Add (replace) Spot_IM_Core.framework to the project’s Frameworks folder, make sure “Copy items if needed” is selected;
2. Make sure the frameworks appears in:
    1. Project -> Main target -> General tab -> Embedded Binaries section
    2. Project -> Main target -> General tab -> Linked frameworks and Libraries section.

## Spot.IM-Example.Pods
This is an example of a project that uses Spot.IM iOS SDK binary (.framework) via **CocoaPods**.

#### To run Spot.IM-Example.Pods:
1. Add Spot.IM spec repo to your system by running the following command in Terminal:  
`pod repo add Spot.IM.Spec git@github.com:SpotIM/spotim-ios-sdk-pod.git`  
2. Run `pod install` in terminal
3. Open Spot.IM-Example.Pods.xcworkspace and run.

#### To add Spot.IM iOS SDK to a project via CocoaPods:
1. Add Spot.IM spec repo to your system by running the following command in Terminal:  
  `pod repo add Spot.IM.Spec git@github.com:SpotIM/spotim-ios-sdk-pod.git`
2. Add spec sources at the top of the podfile:  
  `source 'git@github.com:SpotIM/spotim-ios-sdk-pod.git'`  
  `source 'https://github.com/CocoaPods/Specs.git'`  
3. Set dependency as follows: `pod 'Spot.IM-Core'`
4. Run the following command in Terminal:  
  `pod repo update Spot.IM.Spec`
4. Run the following command to make sure the framework is available via CocoaPods:  
  `pod search Spot.IM`  
5. Run pod install
6. Open workspace file and run

## Create a new Demo App

### Apple delelopers console
1. Go to [Apple developers console](https://developer.apple.com/)
2. In the left side pannel, select 'Certificates IDs & Profiles'
3. In the new opened screen, go to ids
4. create a new app id with the following schema 'im.spot.{new demo app name}'
5. Go to profiles
6. Create new profile for the new id we just created
7. Download the new profile and click on it to install it

### Appstore connet
1. Go to [Appstore connect](https://appstoreconnect.apple.com/)
2. Create a new app
3. Select the id you created in the apple developer console for the app
4. For the SKU type the same as the bundle id

### App icon
1. Ask for a new icon form the PM for the demo app

### xCode project settings
1. Open Spot-IM.Development workspace in xCode and open the project settings
2. Select one of the demo apps targets and duplicate it
3. Change the name of the target to the new demo app name
4. Change the bundle id to the new bundle id created in the Apple developer console
5. Add the icon to the Assets folder
6. In the new demo app project settings select the new icon for the app icon source
7. In the project navigator, look for the new plist for the project and change it's name to the new demo app name
8. Open the new app build settings
9. Look for the plist and change it's name to the new name you selected
10. Change Release signing settings to the new profile you created for this app

### Demo app settings
1. In xCode, open DemoConfiguraiton.swift file
2. Add the new demo app id to the DemoAppsIds enum
3. Add a new case for this new enum with demo articles (see next section on how to create this data)
4. spotId = sp_E6XN2auy
5. spotFontName = roboto
6. spotColor = check the publisher brand color on web if available, if this is a new publisher, ask the PM

### Create demo articles data - for publishers with Spot.IM on web
1. Open the publishers website
2. Go into an article that contains Spot.IM conversation
3. Copy the link as the URL
4. Paste this link back into the converstaion and inspect the web page (filter /extract)
5. In the response to /extract you can find a json object with all the article data

### Configure share links
1. Go to Spot.IM admin panel https://admin.spot.im/
2. Go to spot-id sp_E6XN2auy
3. Go to settings->advanced
4. Add the publisher domain to the 'Authorized URLs' section
