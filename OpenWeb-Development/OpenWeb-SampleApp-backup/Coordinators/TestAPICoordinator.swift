//
//  TestAPICoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class TestAPICoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    // swiftlint:disable function_body_length
    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        let testAPIVM: TestAPIViewModeling = TestAPIViewModel()
        let testAPIVC = TestAPIVC(viewModel: testAPIVM)

        let vcPopped = PublishSubject<Void>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions,
           deepLink == .testAPI || deepLink == .settings || deepLink == .authenticationPlayground {
            shouldAnimate = false
        }

        router.push(testAPIVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        // 1. Define deep links variables
        let deepLinkSettingsScreen = BehaviorSubject<Void?>(value: nil)
        var deepLinkToSettings: Observable<Void> {
            return deepLinkSettingsScreen
                .unwrap()
                .asObservable()
        }

        let deepLinkAuthenticationScreen = BehaviorSubject<Void?>(value: nil)
        var deepLinkToAuthentication: Observable<Void> {
            return deepLinkAuthenticationScreen
                .unwrap()
                .asObservable()
        }

        // 2. Define childs coordinators
        let settingsCoordinator = Observable.merge(testAPIVM.outputs.openSettings.map { nil },
                                                deepLinkToSettings.map { deepLinkOptions})
            .flatMap { [weak self] deepLink -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = SettingsCoordinator(router: self.router)
                return self.coordinate(to: coordinator,
                                       deepLinkOptions: deepLink,
                                       coordinatorData: .settingsScreen(data: SettingsGroupType.all))
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let authenticationPlaygroundCoordinator = Observable.merge(testAPIVM.outputs.openAuthentication.map { nil },
                                                                   deepLinkToAuthentication.map { deepLinkOptions})
            .flatMap { [weak self] deepLink -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinator = AuthenticationPlaygroundCoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let flowsCoordinator = testAPIVM.outputs.openUIFlows
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = UIFlowsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let viewsCoordinator = testAPIVM.outputs.openUIViews
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = UIViewsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

        let miscellaneousCoordinator = testAPIVM.outputs.openMiscellaneous
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = MiscellaneousCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }

#if BETA
        let testingPlauygroundCoordinator = testAPIVM.outputs.openTestingPlayground
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = TestingPlaygroundCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }
#endif

#if AUTOMATION
        let automationCoordinator = testAPIVM.outputs.openAutomation
            .flatMap { [weak self] dataModel -> Observable<Void> in
                guard let self = self else { return .empty() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = AutomationCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> Observable<Void> in
                return .never()
            }
#endif

        // 3. Perfoem deep link if such
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .settings:
                deepLinkSettingsScreen.onNext(())
            case .authenticationPlayground:
                deepLinkAuthenticationScreen.onNext(())
            default:
                break
            }
        }

        var observables: [Observable<Void>] = [vcPopped.asObservable(),
                                               authenticationPlaygroundCoordinator,
                                               settingsCoordinator,
                                               flowsCoordinator,
                                               viewsCoordinator,
                                               miscellaneousCoordinator]

#if BETA
        observables.append(testingPlauygroundCoordinator)
#endif

#if AUTOMATION
        observables.append(automationCoordinator)
#endif

        return Observable.merge(observables)
    }
}
