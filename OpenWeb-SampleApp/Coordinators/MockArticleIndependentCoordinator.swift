//
//  MockArticleIndependentCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class MockArticleIndependentCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.actionsViewSettings(let settings) = data else {
            fatalError("MockArticleIndependentCoordinator requires coordinatorData from `CoordinatorData.actionsViewSettings` type")
        }

        let mockArticleIndependentVM: MockArticleIndependentViewsViewModeling = MockArticleIndependentViewsViewModel(actionSettings: settings)
        let mockArticleIndependentVC = MockArticleIndependentViewsVC(viewModel: mockArticleIndependentVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(mockArticleIndependentVC,
                    animated: true,
                    completion: vcPopped)

        // Define childs coordinators
        let settingsCoordinator = mockArticleIndependentVM.outputs.openSettings
            .flatMap { [weak self] settingsType -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinator = SettingsCoordinator(router: self.router)
                return self.coordinate(to: coordinator,
                                       deepLinkOptions: nil,
                                       coordinatorData: .settingsScreen(data: [settingsType]))
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        return Publishers.Merge(vcPopped,
                                settingsCoordinator)
            .eraseToAnyPublisher()
    }
}
