//
//  MockArticleCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class MockArticleFlowCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.actionsFlowSettings(let settings) = data else {
            fatalError("MockArticleCoordinator requires coordinatorData from `CoordinatorData.actionsFlowSettings` type")
        }

        let mockArticleFlowsVM: MockArticleFlowsViewModeling = MockArticleFlowsViewModel(actionSettings: settings)
        let mockArticleFlowsVC = MockArticleFlowsVC(viewModel: mockArticleFlowsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(mockArticleFlowsVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}
