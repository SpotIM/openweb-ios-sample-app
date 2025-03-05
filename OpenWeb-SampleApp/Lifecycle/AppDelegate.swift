//
//  AppDelegate.swift
//  OpenWeb-Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import UIKit
import Combine
#if ADS
import NimbusSDK
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    var userDefaultsProvider: UserDefaultsProviderProtocol!
    private var cancellables: Set<AnyCancellable> = []

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if ADS
        Nimbus.shared.testMode = true
        #endif

        window = UIWindow(frame: UIScreen.main.bounds)
        appCoordinator = AppCoordinator(window: window!)
        userDefaultsProvider = UserDefaultsProvider.shared
        // Retrieve deep link from the settings of such was set
        let deeplink = userDefaultsProvider.get(key: UserDefaultsProvider.UDKey<SampleAppDeeplink>.deeplinkOption,
                                                defaultValue: .none)

        appCoordinator
            .start(deepLinkOptions: deeplink.toDeepLinkOptions)
            .prefix(1)
            .sink {}
            .store(in: &cancellables)

        return true
    }
}
