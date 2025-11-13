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
    var fullConversationTapped: PassthroughSubject<Void, Never> { get }
    var commentCreationTapped: PassthroughSubject<Void, Never> { get }
    var commentThreadTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIFlowsPartialScreenViewModelingOutputs {
    var title: String { get }
    var openConversationWrapperFlow: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> { get }
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

    let fullConversationTapped = PassthroughSubject<Void, Never>()
    let commentCreationTapped = PassthroughSubject<Void, Never>()
    let commentThreadTapped = PassthroughSubject<Void, Never>()

    private let _openConversationWrapperFlow = PassthroughSubject<SDKUIFlowPartialScreenActionSettings, Never>()
    var openConversationWrapperFlow: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> {
        return _openConversationWrapperFlow
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

        Publishers.Merge3(
            fullConversationModel,
            commentCreationModel,
            commentThreadModel
        )
            .bind(to: _openConversationWrapperFlow)
            .store(in: &cancellables)
    }
}
