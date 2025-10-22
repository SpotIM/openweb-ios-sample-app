//
//  TestAPICoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class TestAPICoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    // swiftlint:disable function_body_length
    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {
        let testAPIVM: TestAPIViewModeling = TestAPIViewModel()
        let testAPIVC = TestAPIVC(viewModel: testAPIVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        var shouldAnimate = true
        if let deepLink = deepLinkOptions,
           deepLink == .testAPI || deepLink == .settings || deepLink == .authenticationPlayground {
            shouldAnimate = false
        }

        router.push(testAPIVC,
                    animated: shouldAnimate,
                    completion: vcPopped)

        // 1. Define deep links variables
        let deepLinkSettingsScreen = CurrentValueSubject<Void?, Never>(value: nil)
        var deepLinkToSettings: AnyPublisher<Void, Never> {
            return deepLinkSettingsScreen
                .unwrap()
                .eraseToAnyPublisher()
        }

        let deepLinkAuthenticationScreen = CurrentValueSubject<Void?, Never>(value: nil)
        var deepLinkToAuthentication: AnyPublisher<Void, Never> {
            return deepLinkAuthenticationScreen
                .unwrap()
                .eraseToAnyPublisher()
        }

        // 2. Define childs coordinators
        let settingsCoordinator = Publishers.MergeMany(testAPIVM.outputs.openSettings.map { nil },
                                                deepLinkToSettings.map { deepLinkOptions })
            .flatMap { [weak self] deepLink -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinator = SettingsCoordinator(router: self.router)
                return self.coordinate(to: coordinator,
                                       deepLinkOptions: deepLink,
                                       coordinatorData: .settingsScreen(data: SettingsGroupType.all))
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let authenticationPlaygroundCoordinator = Publishers.MergeMany(testAPIVM.outputs.openAuthentication.map { nil },
                                                                   deepLinkToAuthentication.map { deepLinkOptions })
            .flatMap { [weak self] deepLink -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinator = AuthenticationPlaygroundCoordinator(router: self.router)
                return self.coordinate(to: coordinator, deepLinkOptions: deepLink)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let flowsCoordinator = testAPIVM.outputs.openUIFlows
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = UIFlowsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let flowsPartialScreenCoordinator = testAPIVM.outputs.openUIFlowsPartialScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = UIFlowsPartialScreenCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let viewsCoordinator = testAPIVM.outputs.openUIViews
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = UIViewsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        let miscellaneousCoordinator = testAPIVM.outputs.openMiscellaneous
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = MiscellaneousCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

#if BETA
        let testingPlauygroundCoordinator = testAPIVM.outputs.openTestingPlayground
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = TestingPlaygroundCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
#endif

#if AUTOMATION
        let automationCoordinator = testAPIVM.outputs.openAutomation
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.conversationDataModel(data: dataModel)
                let coordinator = AutomationCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
#endif

        // 3. Perfoem deep link if such
        if let deepLink = deepLinkOptions {
            switch deepLink {
            case .settings:
                deepLinkSettingsScreen.send(())
            case .authenticationPlayground:
                deepLinkAuthenticationScreen.send(())
            default:
                break
            }
        }

        var observables: [AnyPublisher<Void, Never>] = [
            vcPopped.eraseToAnyPublisher(),
            authenticationPlaygroundCoordinator,
            settingsCoordinator,
            flowsCoordinator,
            flowsPartialScreenCoordinator,
            viewsCoordinator,
            miscellaneousCoordinator,
        ]

#if BETA
        observables.append(testingPlauygroundCoordinator)
#endif

#if AUTOMATION
        observables.append(automationCoordinator)
#endif

        return Publishers.MergeMany(observables)
            .eraseToAnyPublisher()
    }
}
