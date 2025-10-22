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

        let mockArticleFlowCoordinator = flowsVM.outputs.openMockArticleScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.actionsFlowPartialScreenSettings(data: dataModel)
                let coordinator = MockArticleFlowPartialScreenCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        let viewsExamplesCoordinator = flowsVM.outputs.openExamplesScreen
            .flatMap { [weak self] dataModel -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let coordinatorData = CoordinatorData.postId(data: dataModel)
                let coordinator = UIFlowsPartialScreenExamplesCoordinator(router: self.router)
                return self.coordinate(to: coordinator, coordinatorData: coordinatorData)
            }
            .flatMap { _ -> AnyPublisher<Void, Never> in
                return Empty(completeImmediately: false).eraseToAnyPublisher()
            }

        return Publishers.Merge3(vcPopped,
                                 mockArticleFlowCoordinator,
                                 viewsExamplesCoordinator)
        .eraseToAnyPublisher()
    }
}
