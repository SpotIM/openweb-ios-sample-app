//
//  AppDelegate.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SpotImCore
import GoogleMobileAds
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Custom fonts example
        // SpotIm.customFontFamiliy = "BigShouldersDisplay"
//        IQKeyboardManager.shared().isEnabled = false
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        IQKeyboardManager.shared().isEnableAutoToolbar = true
//        UserDefaults.standard.removeObject(forKey: "shouldShowOpenFullConversation")
//        UserDefaults.standard.removeObject(forKey: "shouldPresentInNewNavStack")
        
        return true
    }
}
