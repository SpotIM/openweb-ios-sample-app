//
//  OWViewsSDKCoordinator.swift
//  SpotImCore
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWViewsSDKCoordinator: OWBaseCoordinator<Void>, OWCompactRouteringCompatible {
    fileprivate var compactRouter: OWCompactRoutering!

    var compactRoutering: OWCompactRoutering {
        return retrieveCompactRouter()
    }

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func startPreConversationFlow(preConversationData: OWPreConversationRequiredData,
                                  presentationalMode: OWPresentationalMode,
                                  callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {

        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: .preConversation)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let preConversationCoordinator = OWPreConversationCoordinator(preConversationData: preConversationData,
                                                                              actionsCallbacks: callbacks)
                self.store(coordinator: preConversationCoordinator)
                return preConversationCoordinator.showableComponent()
            }
    }
}

fileprivate extension OWViewsSDKCoordinator {
    func retrieveCompactRouter() -> OWCompactRoutering {
        let compactRouter: OWCompactRouter

        if let appWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
           let topController = topViewController(fromBase: appWindow.rootViewController) {
            compactRouter = OWCompactRouter(topController: topController)
            return compactRouter
        }

        let logger = servicesProvider.logger()
        logger.log(level: .error, "Can't find top controller when running in UIViews mode. Returning an epmty `OWCompactRouter`")
        compactRouter = OWCompactRouter(topController: nil)
        return compactRouter
    }

    func topViewController(fromBase base: UIViewController?) -> UIViewController? {
        // Finding top view controller from base. Using recursion in this function
            if let navController = base as? UINavigationController {
                return topViewController(fromBase: navController.visibleViewController)
            } else if let tabController = base as? UITabBarController {
                if let selectedTab = tabController.selectedViewController {
                    return topViewController(fromBase: selectedTab)
                }
            } else if let presentedController = base?.presentedViewController {
                return topViewController(fromBase: presentedController)
            }

            return base
    }
}
