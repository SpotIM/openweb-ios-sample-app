//
//  UIFlowsExamplesViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 28/09/2025.
//

import Foundation
import Combine
import OpenWebSDK

protocol UIFlowsExamplesViewModelingInputs {
    var conversationBelowVideoTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIFlowsExamplesViewModelingOutputs {
    var title: String { get }
    var openConversationBelowVideo: AnyPublisher<OWPostId, Never> { get }
}

protocol UIFlowsExamplesViewModeling {
    var inputs: UIFlowsExamplesViewModelingInputs { get }
    var outputs: UIFlowsExamplesViewModelingOutputs { get }
}

class UIFlowsExamplesViewModel: UIFlowsExamplesViewModeling, UIFlowsExamplesViewModelingOutputs, UIFlowsExamplesViewModelingInputs {
    var inputs: UIFlowsExamplesViewModelingInputs { return self }
    var outputs: UIFlowsExamplesViewModelingOutputs { return self }

    private let postId: OWPostId
    private var cancellables = Set<AnyCancellable>()

    let conversationBelowVideoTapped = PassthroughSubject<Void, Never>()

    private let _openConversationBelowVideo = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openConversationBelowVideo: AnyPublisher<OWPostId, Never> {
        return _openConversationBelowVideo
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("Examples", comment: "")
    }()

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

private extension UIFlowsExamplesViewModel {
    func setupObservers() {
        conversationBelowVideoTapped
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openConversationBelowVideo)
            .store(in: &cancellables)
    }
}
