//
//  UIFlowsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

class UIFlowsCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("UIFlowsCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let flowsVM: UIFlowsViewModeling = UIFlowsViewModel(dataModel: conversationDataModel)
        let flowsVC = UIFlowsVC(viewModel: flowsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(flowsVC,
                    animated: true,
                    completion: vcPopped)

        let mockArticleFlowCoordinator = flowsVM.outputs.openMockArticleScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.actionsFlowSettings(data: dataModel)
                let coordinator = MockArticleFlowCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        let viewsExamplesCoordinator = flowsVM.outputs.openExamplesScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = UIViewsExamplesCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        let monetizationCoordinator = flowsVM.outputs.openMonetizationScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = MonetizationFlowsCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        return Publishers.Merge4(vcPopped,
                                 mockArticleFlowCoordinator,
                                 viewsExamplesCoordinator,
                                 monetizationCoordinator)
        .eraseToAnyPublisher()
    }
}
