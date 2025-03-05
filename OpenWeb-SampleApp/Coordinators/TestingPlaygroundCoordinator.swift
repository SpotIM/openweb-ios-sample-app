//
//  TestingPlaygroundCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

#if BETA

import Foundation
import Combine

class TestingPlaygroundCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("TestingPlaygroundCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let testingPlaygroundVM: TestingPlaygroundViewModeling = TestingPlaygroundViewModel(dataModel: conversationDataModel)
        let testingPlaygroundVC = TestingPlaygroundVC(viewModel: testingPlaygroundVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        setupCoordinatorInternalNavigation(viewModel: testingPlaygroundVM)

        router.push(testingPlaygroundVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}

private extension TestingPlaygroundCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: TestingPlaygroundViewModeling) {
        viewModel.outputs.openTestingPlaygroundIndependent
            .sink(receiveValue: { [weak self] dataModel in
                guard let self else { return }
                let testingPlaygroundIndependentVM = TestingPlaygroundIndependentViewModel(dataModel: dataModel)
                let testingPlaygroundIndependentVC = TestingPlaygroundIndependentViewVC(viewModel: testingPlaygroundIndependentVM)
                self.router.push(testingPlaygroundIndependentVC,
                            animated: true,
                            completion: nil)
            })
            .store(in: &cancellables)
    }
}

#endif
