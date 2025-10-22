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
    var preConversationTapped: PassthroughSubject<Void, Never> { get }
    var fullConversationTapped: PassthroughSubject<Void, Never> { get }
    var commentCreationTapped: PassthroughSubject<Void, Never> { get }
    var commentThreadTapped: PassthroughSubject<Void, Never> { get }
    var examplesTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIFlowsPartialScreenViewModelingOutputs {
    var title: String { get }
    var openMockArticleScreen: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> { get }
    var openExamplesScreen: AnyPublisher<OWPostId, Never> { get }
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

    let preConversationTapped = PassthroughSubject<Void, Never>()
    let fullConversationTapped = PassthroughSubject<Void, Never>()
    let commentCreationTapped = PassthroughSubject<Void, Never>()
    let commentThreadTapped = PassthroughSubject<Void, Never>()
    let examplesTapped = PassthroughSubject<Void, Never>()

    private let _openMockArticleScreen = CurrentValueSubject<SDKUIFlowPartialScreenActionSettings?, Never>(value: nil)
    var openMockArticleScreen: AnyPublisher<SDKUIFlowPartialScreenActionSettings, Never> {
        return _openMockArticleScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _openExamplesScreen = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openExamplesScreen: AnyPublisher<OWPostId, Never> {
        return _openExamplesScreen
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

        let preConversationModel = preConversationTapped
            .map { _ -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .preConversation)
            }
            .eraseToAnyPublisher()

        let fullConversationModel = fullConversationTapped
            .map { route -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .fullConversation)
            }
            .eraseToAnyPublisher()

        let commentCreationTappedModel = commentCreationTapped
            .map { route -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .commentCreation)
            }
            .eraseToAnyPublisher()

        let commentThreadTappedModel = commentThreadTapped
            .map { route -> SDKUIFlowPartialScreenActionSettings in
                return SDKUIFlowPartialScreenActionSettings(postId: postId, actionType: .commentThread)
            }
            .eraseToAnyPublisher()

        Publishers.MergeMany(preConversationModel, fullConversationModel, commentCreationTappedModel, commentThreadTappedModel)
            .map { $0 } // swiftlint:disable:this array_init
            .bind(to: _openMockArticleScreen)
            .store(in: &cancellables)

        examplesTapped
            .map { postId }
            .bind(to: _openExamplesScreen)
            .store(in: &cancellables)
    }
}
