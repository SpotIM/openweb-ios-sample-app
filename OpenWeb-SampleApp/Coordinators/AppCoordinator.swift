//
//  AppCoordinator.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import RxSwift
import OpenWebSDK
import UIKit
import GoogleMobileAds
import OpenWebIAUSDK

#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow
    private var router: Routering!

    init(window: UIWindow) {
        self.window = window
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        initialSetup()

        let mainPageCoordinator = MainPageCoordinator(router: router)

        return coordinate(to: mainPageCoordinator, deepLinkOptions: deepLinkOptions)
    }
}

private extension AppCoordinator {
    func initialSetup() {
        initialVendorsSetup()
        initialDataSetup()
        initialUIAppearance()
        initialIAUSetup()
    }

    func initialVendorsSetup() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    func initialDataSetup() {
        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldShowOpenFullConversation)
        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldPresentInNewNavStack)
        UserDefaultsProvider.shared.remove(key: UserDefaultsProvider.UDKey<Bool>.shouldOpenComment)
    }

    func initialUIAppearance() {
        let navigation = SampleAppNavigationController.shared
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        router = Router(navigationController: navigation)
    }
    
    func initialIAUSetup() {
        let exampleStoreURL = "https://apps.apple.com/us/app/spotim-demo/id1234567"
        var manager = OpenWebIAU.manager
        manager.spotId = "sp_PPSI75uf" //TODO: When the spots of the example app will have the option to show an ad, we will switch here to the current spot of the application app.
        var settingsBuilder = OWIAUSettingsBuilder()
        settingsBuilder.storeURL(exampleStoreURL)
        manager.settings = settingsBuilder.build()
    }
}
