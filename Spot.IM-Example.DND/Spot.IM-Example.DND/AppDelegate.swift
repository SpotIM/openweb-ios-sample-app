//
//  AppDelegate.swift
//  Spot.IM-Example.DND
//
//  Created by Andriy Fedin on 19/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Spot_IM_Core

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        SPClientSettings.spotKey = "sp_ly3RvXf6"

        return true
    }
}

