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

    func preConversationView(preConversationData: OWPreConversationRequiredData,
                             callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {

        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.generateNewPageViewId()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWPreConversationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let preConversationCoordinator = OWPreConversationCoordinator(preConversationData: preConversationData,
                                                                              actionsCallbacks: callbacks,
                                                                              viewableMode: .independent)
                self.store(coordinator: preConversationCoordinator)
                return preConversationCoordinator.showableComponent()
            }
    }

    func conversationView(conversationData: OWConversationRequiredData,
                          callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.generateNewPageViewId()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWConversationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let conversationCoordinator = OWConversationCoordinator(conversationData: conversationData,
                                                                              actionsCallbacks: callbacks)
                self.store(coordinator: conversationCoordinator)
                return conversationCoordinator.showableComponent()
            }
    }

    func commentCreationView(commentCreationData: OWCommentCreationRequiredData,
                             callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWCommentCreationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let commentCreationCoordinator = OWCommentCreationCoordinator(commentCreationData: commentCreationData,
                                                                           actionsCallbacks: callbacks)
                self.store(coordinator: commentCreationCoordinator)
                return commentCreationCoordinator.showableComponent()
            }
    }

    func commentThreadView(commentThreadData: OWCommentThreadRequiredData,
                           callbacks: OWViewActionsCallbacks?
    ) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWCommentThreadCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let commentThreadCoordinator = OWCommentThreadCoordinator(commentThreadData: commentThreadData,
                                                                          actionsCallbacks: callbacks)
                self.store(coordinator: commentThreadCoordinator)
                return commentThreadCoordinator.showableComponent()
            }
    }

    func reportReasonView(reportData: OWReportReasonsRequiredData,
                          callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWReportReasonCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let reportReasonCoordinator = OWReportReasonCoordinator(reportData: reportData,
                                                                            actionsCallbacks: callbacks)
                    self.store(coordinator: reportReasonCoordinator)
                    return reportReasonCoordinator.showableComponent()
                }
    }

    func clarityDetailsView(type: OWClarityDetailsType,
                            callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWClarityDetailsCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let clarityDetailsCoordinator = OWClarityDetailsCoordinator(type: type, actionsCallbacks: callbacks)

                    self.store(coordinator: clarityDetailsCoordinator)
                    return clarityDetailsCoordinator.showableComponent()
                }
    }

#if BETA
    func testingPlaygroundView(testingPlaygroundData: OWTestingPlaygroundRequiredData,
                               callbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWTestingPlaygroundCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let testingPlaygroundCoordinator = OWTestingPlaygroundCoordinator(testingPlaygroundData: testingPlaygroundData,
                                                                                      actionsCallbacks: callbacks)
                    self.store(coordinator: testingPlaygroundCoordinator)
                    return testingPlaygroundCoordinator.showableComponent()
                }
    }
#endif
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

    func generateNewPageViewId() {
        let pageViewIdHolder = servicesProvider.pageViewIdHolder()
        pageViewIdHolder.generateNewPageViewId()
    }
}
