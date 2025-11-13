//
//  UIFlowsPartialScreenViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import Foundation
import Combine
import OpenWebSDK

protocol UIFlowsPartialScreenViewModelingInputs {
    var preConversationToFullConversationPushModeTapped: PassthroughSubject<Void, Never> { get }
    var preConversationToFullConversationPresentModeTapped: PassthroughSubject<Void, Never> { get }
    var preConversationToFullConversationCoverModeTapped: PassthroughSubject<Void, Never> { get }
    var fullConversationTapped: PassthroughSubject<Void, Never> { get }
    var commentCreationTapped: PassthroughSubject<Void, Never> { get }
    var commentThreadTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIFlowsPartialScreenViewModelingOutputs {
    var title: String { get }
    var openMockArticleScreen: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> { get }
    var openConversationBelowVideoScreen: AnyPublisher<OWPostId, Never> { get }
}

protocol UIFlowsPartialScreenViewModeling {
    var inputs: UIFlowsPartialScreenViewModelingInputs { get }
    var outputs: UIFlowsPartialScreenViewModelingOutputs { get }
}

class UIFlowsPartialScreenViewModel: UIFlowsPartialScreenViewModeling, UIFlowsPartialScreenViewModelingOutputs, UIFlowsPartialScreenViewModelingInputs {
    var inputs: UIFlowsPartialScreenViewModelingInputs { return self }
    var outputs: UIFlowsPartialScreenViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    private var cancellables = Set<AnyCancellable>()

    let preConversationToFullConversationPushModeTapped = PassthroughSubject<Void, Never>()
    let preConversationToFullConversationPresentModeTapped = PassthroughSubject<Void, Never>()
    let preConversationToFullConversationCoverModeTapped = PassthroughSubject<Void, Never>()
    let fullConversationTapped = PassthroughSubject<Void, Never>()
    let commentCreationTapped = PassthroughSubject<Void, Never>()
    let commentThreadTapped = PassthroughSubject<Void, Never>()

    private let _openMockArticleScreen = CurrentValueSubject<SDKUIFlowPartialScreenActionSettings?, Never>(value: nil)
    var openMockArticleScreen: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> {
        return _openMockArticleScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _openConversationBelowVideoScreen = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openConversationBelowVideoScreen: AnyPublisher<OWPostId, Never> {
        return _openConversationBelowVideoScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("UIFlowsPartialScreen", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension UIFlowsPartialScreenViewModel {

    func setupObservers() {
        let postId = dataModel.postId

        let preConversationToFullConversationPushModeModel = preConversationToFullConversationPushModeTapped
            .map { route -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .preConversationToFullConversation(presentationalMode: .push))
            }
            .eraseToAnyPublisher()

        let preConversationToFullConversationPresentModeModel = preConversationToFullConversationPresentModeTapped
            .map { route -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .preConversationToFullConversation(presentationalMode: .present(style: .fullScreen)))
            }
            .eraseToAnyPublisher()

        let fullConversationModel = fullConversationTapped
            .map { _ -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .fullConversation(route: .none))
            }
            .eraseToAnyPublisher()

        let commentCreationModel = commentCreationTapped
            .map { _ -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .fullConversation(route: .commentCreation(type: .comment)))
            }
            .eraseToAnyPublisher()

        let commentThreadModel = commentThreadTapped
            .map { _ -> SDKUIFlowPartialScreenActionSettings in
                let commentId = OWCommentThreadSettings.defaultCommentId
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .fullConversation(route: .commentThread(commentId: commentId)))
            }
            .eraseToAnyPublisher()

        Publishers.MergeMany([
            preConversationToFullConversationPushModeModel,
            preConversationToFullConversationPresentModeModel,
            fullConversationModel,
            commentCreationModel,
            commentThreadModel
        ])
            .map { $0 } // swiftlint:disable:this array_init
            .bind(to: _openMockArticleScreen)
            .store(in: &cancellables)

        preConversationToFullConversationCoverModeTapped
            .map { postId }
            .bind(to: _openConversationBelowVideoScreen)
            .store(in: &cancellables)
    }
}
