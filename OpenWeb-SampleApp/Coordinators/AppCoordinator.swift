//
//  AppCoordinator.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import RxSwift
import OpenWebSDK
import UIKit

#if ADS
import OpenWebIAUSDK
#endif

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

        #if ADS
        initialMonetizationSetup()
        #endif
    }

    func initialVendorsSetup() {
    }

    func initialDataSetup() {
    }

    func initialUIAppearance() {
        let navigation = SampleAppNavigationController.shared
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        router = Router(navigationController: navigation)
    }

    #if ADS
    func initialMonetizationSetup() {
        var manager = OpenWebIAU.manager
        var settingsBuilder = OWIAUSettingsBuilder()
        settingsBuilder.storeURL(AppConstants.exampleStoreURL)
        manager.settings = settingsBuilder.build()

        var socialManagerMonetization = OpenWeb.manager.monetization
        socialManagerMonetization.iauProvider = manager.helpers.getIAUProvider()
    }
    #endif
}
