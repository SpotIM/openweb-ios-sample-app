//
//  AppDelegate.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Custom fonts example
//         SpotIm.customFontFamily = "Roboto"
        
        UserDefaults.standard.removeObject(forKey: "shouldShowOpenFullConversation")
        UserDefaults.standard.removeObject(forKey: "shouldPresentInNewNavStack")
        UserDefaults.standard.removeObject(forKey: "shouldOpenComment")
        
        return true
    }
}
