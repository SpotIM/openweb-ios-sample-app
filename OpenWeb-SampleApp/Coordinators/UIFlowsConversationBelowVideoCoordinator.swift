//
//  UIFlowsConversationBelowVideoCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Foundation
import Combine

class UIFlowsConversationBelowVideoCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> AnyPublisher<Void, Never> {

        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("UIFlowsConversationBelowVideoCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let vcPopped = PassthroughSubject<Void, Never>()

        let conversationBelowVideoVM = UIFlowsConversationBelowVideoViewModel(postId: postId)
        let conversationBelowVideoVC = UIFlowsConversationBelowVideoVC(viewModel: conversationBelowVideoVM)
        self.router.push(conversationBelowVideoVC,
                         animated: true,
                         completion: nil)

        return vcPopped
            .eraseToAnyPublisher()
    }
}
