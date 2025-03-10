//
//  AppDelegate.swift
//  OpenWeb-Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
#if ADS
import NimbusSDK
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    var userDefaultsProvider: UserDefaultsProviderProtocol!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if ADS
        Nimbus.shared.testMode = true
        #endif

        #if canImport(InjectHotReload)
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        UIView.setupSwizzlingForHotReload()
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)
        userDefaultsProvider = UserDefaultsProvider.shared
        // Retrieve deep link from the settings of such was set
        let deeplink = userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<SampleAppDeeplink>.deeplinkOption,
                                                defaultValue: .none)

        // No need to dispose, as we are taking only one and this observable should also never end
        _ = appCoordinator
            .start(deepLinkOptions: deeplink.toDeepLinkOptions)
            .take(1)
            .subscribe()

        return true
    }
}
