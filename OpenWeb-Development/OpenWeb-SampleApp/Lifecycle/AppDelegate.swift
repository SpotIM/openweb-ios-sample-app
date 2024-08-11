//
//  AppDelegate.swift
//  OpenWeb-Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)

        // No need to dispose, as we are taking only one and this observable should also never end
        _ = appCoordinator
            .start(deepLinkOptions: nil)
            .take(1)
            .subscribe()

        return true
    }
}
