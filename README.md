# spotim-ios-sdk-demo-apps
In this repository:
* Development app for developing Spot.IM SDK
* Demo apps for testing the SDK

## Spot.IM-Development
This project is for Spot.IM iOS SDK development.

#### To run Spot.IM-Development:
1. Add spotim-ios-sdk ([from here](https://github.com/SpotIM/spotim-ios-sdk)) as a subfolder to Spot.IM-Development folder
2. Install pods (`pod install` in terminal) in the Spot.IM-Development folder
3. Open the workspace, not the project
4. Check Pods framework
    1. Go to Spot.IM-Core target of the Spot.IM-Core.xcodeproj
    2. Build Phases tab
    3. Link Binary With Libraries section
    4. Make sure there’s Pods_Spot_IM_Development.framework added (not Pods_Spot_IM_Core.framework)
    5. If it's not the case, replace it (it's in the folder)
5. Run Spot-IM.Development target

## Spot.IM-Example.DND
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
