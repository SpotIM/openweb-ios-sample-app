//
//  MockArticleFlowPartialScreenCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation
import Combine

class MockArticleFlowPartialScreenCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.actionsFlowPartialScreenSettings(let settings) = data else {
            fatalError("MockArticleCoordinator requires coordinatorData from `CoordinatorData.actionsFlowPartialScreenSettings` type")
        }

        let mockArticleFlowsVM: MockArticleFlowsPartialScreenViewModeling = MockArticleFlowsPartialScreenViewModel(actionSettings: settings)
        let mockArticleFlowsVC = MockArticleFlowsPartialScreenVC(viewModel: mockArticleFlowsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(mockArticleFlowsVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}
