//
//  UIFlowsPartialScreenCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation
import Combine

class UIFlowsPartialScreenCoordinator: BaseCoordinator<Void> {

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

        let flowsVM: UIFlowsPartialScreenViewModeling = UIFlowsPartialScreenViewModel(dataModel: conversationDataModel)
        let flowsVC = UIFlowsPartialScreenVC(viewModel: flowsVM)

        let vcPopped = PassthroughSubject<Void, Never>()

        router.push(flowsVC,
                    animated: true,
                    completion: vcPopped)

        let conversationWrapperCoordinator = flowsVM.outputs.openConversationWrapperFlow
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.actionsFlowPartialScreenSettings(data: dataModel)
                let coordinator = ConversationWrapperFlowCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return Publishers.MergeMany([
            vcPopped.eraseToAnyPublisher(),
            conversationWrapperCoordinator,
        ])
        .eraseToAnyPublisher()
    }
}
