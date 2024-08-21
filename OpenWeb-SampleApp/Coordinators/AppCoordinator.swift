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
import FirebaseCore
#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

class AppCoordinator: BaseCoordinator<Void> {

    fileprivate let window: UIWindow
    fileprivate var router: Routering!

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

fileprivate extension AppCoordinator {
    func initialSetup() {
        initialVendorsSetup()
        initialDataSetup()
        initialUIAppearance()
    }

    func initialVendorsSetup() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)

#if !(DEBUG) && !PUBLIC_DEMO_APP
        if let firebaseFilePath = Bundle.openWebInternalConfigs
            .path(forResource: "GoogleService-Info", ofType: "plist"),
           let firebaseOptions = FirebaseOptions(contentsOfFile: firebaseFilePath) {

            FirebaseApp.configure(options: firebaseOptions)
        }
#endif
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
}

