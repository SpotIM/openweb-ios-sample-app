//
//  OWViewsSDKCoordinator.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWViewsSDKCoordinator: OWBaseCoordinator<Void>, OWCompactRouteringCompatible {
    private var compactRouter: OWCompactRoutering!

    var compactRoutering: OWCompactRoutering {
        return retrieveCompactRouter()
    }

    private let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    func preConversationView(preConversationData: OWPreConversationRequiredData,
                             viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {

        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
                self.generateNewPageViewId()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWPreConversationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let preConversationCoordinator = OWPreConversationCoordinator(preConversationData: preConversationData,
                                                                              viewActionsCallbacks: viewCallbacks,
                                                                              viewableMode: .independent)
                self.store(coordinator: preConversationCoordinator)
                return preConversationCoordinator.showableComponent()
            }
    }

    func conversationView(conversationData: OWConversationRequiredData,
                          viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
                self.generateNewPageViewId()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWConversationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let conversationCoordinator = OWConversationCoordinator(conversationData: conversationData,
                                                                        viewActionsCallbacks: viewCallbacks,
                                                                        flowActionsCallbacks: nil)
                self.store(coordinator: conversationCoordinator)
                return conversationCoordinator.showableComponent()
            }
    }

    func commentCreationView(commentCreationData: OWCommentCreationRequiredData,
                             viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWCommentCreationCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let commentCreationCoordinator = OWCommentCreationCoordinator(commentCreationData: commentCreationData,
                                                                           viewActionsCallbacks: viewCallbacks)
                self.store(coordinator: commentCreationCoordinator)
                return commentCreationCoordinator.showableComponent()
            }
    }

    func commentThreadView(commentThreadData: OWCommentThreadRequiredData,
                           viewCallbacks: OWViewActionsCallbacks?
    ) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWCommentThreadCoordinatorResult>.self)
            })
            .flatMap { [ weak self] _ -> Observable<OWShowable> in
                guard let self = self else { return .empty() }
                let commentThreadCoordinator = OWCommentThreadCoordinator(commentThreadData: commentThreadData,
                                                                          viewActionsCallbacks: viewCallbacks,
                                                                          flowActionsCallbacks: nil)
                self.store(coordinator: commentThreadCoordinator)
                return commentThreadCoordinator.showableComponent()
            }
    }

    func reportReasonView(reportData: OWReportReasonsRequiredData,
                          viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWReportReasonCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let reportReasonCoordinator = OWReportReasonCoordinator(reportData: reportData,
                                                                            viewActionsCallbacks: viewCallbacks)
                    self.store(coordinator: reportReasonCoordinator)
                    return reportReasonCoordinator.showableComponent()
                }
    }

    func clarityDetailsView(data: OWClarityDetailsRequireData,
                            viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWClarityDetailsCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let clarityDetailsCoordinator = OWClarityDetailsCoordinator(data: data, viewActionsCallbacks: viewCallbacks)

                    self.store(coordinator: clarityDetailsCoordinator)
                    return clarityDetailsCoordinator.showableComponent()
                }
    }

    func commenterAppealView(appealData: OWAppealRequiredData,
                             viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWCommenterAppealCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let commenterAppealCoordinator = OWCommenterAppealCoordinator(appealData: appealData, viewActionsCallbacks: viewCallbacks)

                    self.store(coordinator: commenterAppealCoordinator)
                    return commenterAppealCoordinator.showableComponent()
                }
    }

    func webTabView(tabOptions: OWWebTabOptions, viewCallbacks: OWViewActionsCallbacks?) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWWebTabCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let webTabCoordinator = OWWebTabCoordinator(options: tabOptions, viewActionsCallbacks: viewCallbacks)

                    self.store(coordinator: webTabCoordinator)
                    return webTabCoordinator.showableComponent()
                }
    }

#if BETA
    func testingPlaygroundView(testingPlaygroundData: OWTestingPlaygroundRequiredData) -> Observable<OWShowable> {
        return Observable.just(())
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.prepareForIndependentViewMode()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.free(allCoordinatorsFromType: OWBaseCoordinator<OWTestingPlaygroundCoordinatorResult>.self)
            })
                .flatMap { [ weak self] _ -> Observable<OWShowable> in
                    guard let self = self else { return .empty() }
                    let testingPlaygroundCoordinator = OWTestingPlaygroundCoordinator(testingPlaygroundData: testingPlaygroundData)
                    self.store(coordinator: testingPlaygroundCoordinator)
                    return testingPlaygroundCoordinator.showableComponent()
                }
    }
#endif
}

private extension OWViewsSDKCoordinator {
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

    func prepareForIndependentViewMode() {
        let orientationService = servicesProvider.orientationService()
        orientationService.set(viewableMode: .independent)
    }

    func generateNewPageViewId() {
        let pageViewIdHolder = servicesProvider.pageViewIdHolder()
        pageViewIdHolder.generateNewPageViewId()
    }
}
