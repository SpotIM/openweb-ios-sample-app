//
//  AppCoordinator.swift
//  OpenWeb-iOS-SDK-Demo
//
//  Created by Alon Haiut on 29/11/2021.
//

import RxSwift
import OpenWebSDK
import UIKit

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
    }

    func initialVendorsSetup() {
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
