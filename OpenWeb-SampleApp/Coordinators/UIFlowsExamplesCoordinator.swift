//
//  UIFlowsExamplesCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Foundation
import Combine

class UIFlowsExamplesCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("UIFlowsExamplesCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let examplesViewModel: UIFlowsExamplesViewModeling = UIFlowsExamplesViewModel(postId: postId)
        let examplesVC = UIFlowsExamplesVC(viewModel: examplesViewModel)

        let vcPopped = PassthroughSubject<Void, Never>()

        setupCoordinatorInternalNavigation(viewModel: examplesViewModel)

        router.push(examplesVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .eraseToAnyPublisher()
    }
}

private extension UIFlowsExamplesCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: UIFlowsExamplesViewModeling) {
        viewModel.outputs.openConversationBelowVideo
            .sink(receiveValue: { [weak self] postId in
                guard let self else { return }
                // TODO: Implement for Flows
//                let conversationBelowVideoVM = UIViewsConversationBelowVideoViewModel(postId: postId)
//                let conversationBelowVideoVC = UIViewsConversationBelowVideoVC(viewModel: conversationBelowVideoVM)
//                self.router.push(conversationBelowVideoVC,
//                                 animated: true,
//                                 completion: nil)
            })
            .store(in: &cancellables)
    }
}
