//
//  UIViewsExamplesViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol UIViewsExamplesViewModelingInputs {
    var conversationBelowVideoTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIViewsExamplesViewModelingOutputs {
    var title: String { get }
    var openConversationBelowVideo: AnyPublisher<OWPostId, Never> { get }
}

protocol UIViewsExamplesViewModeling {
    var inputs: UIViewsExamplesViewModelingInputs { get }
    var outputs: UIViewsExamplesViewModelingOutputs { get }
}

class UIViewsExamplesViewModel: UIViewsExamplesViewModeling, UIViewsExamplesViewModelingOutputs, UIViewsExamplesViewModelingInputs {
    var inputs: UIViewsExamplesViewModelingInputs { return self }
    var outputs: UIViewsExamplesViewModelingOutputs { return self }

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

private extension UIViewsExamplesViewModel {
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
