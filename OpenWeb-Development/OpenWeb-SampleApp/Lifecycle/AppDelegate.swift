//
//  AppDelegate.swift
//  OpenWeb-Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit
import OpenWebSDK
import GoogleMobileAds
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        // Custom fonts example
//         SpotIm.customFontFamily = "Roboto"

        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldShowOpenFullConversation)
        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldPresentInNewNavStack)
        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldOpenComment)

        #if !(DEBUG)
        FirebaseApp.configure()
        #endif

        return true
    }
}
