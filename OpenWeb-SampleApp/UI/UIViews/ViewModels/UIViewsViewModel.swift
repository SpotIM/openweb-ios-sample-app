//
//  UIViewsViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 07/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol UIViewsViewModelingInputs {
    var preConversationTapped: PassthroughSubject<Void, Never> { get }
    var fullConversationTapped: PassthroughSubject<Void, Never> { get }
    var commentCreationTapped: PassthroughSubject<Void, Never> { get }
    var commentThreadTapped: PassthroughSubject<Void, Never> { get }
    var clarityDetailsTapped: PassthroughSubject<Void, Never> { get }
    var monetizationTapped: PassthroughSubject<Void, Never> { get }
    var examplesTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIViewsViewModelingOutputs {
    var title: String { get }
    var openMockArticleScreen: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> { get }
    var openExamplesScreen: AnyPublisher<OWPostId, Never> { get }
    var openMonetizationScreen: AnyPublisher<OWPostId, Never> { get }
}

protocol UIViewsViewModeling {
    var inputs: UIViewsViewModelingInputs { get }
    var outputs: UIViewsViewModelingOutputs { get }
}

class UIViewsViewModel: UIViewsViewModeling, UIViewsViewModelingOutputs, UIViewsViewModelingInputs {
    var inputs: UIViewsViewModelingInputs { return self }
    var outputs: UIViewsViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    private var cancellables = Set<AnyCancellable>()

    let preConversationTapped = PassthroughSubject<Void, Never>()
    let fullConversationTapped = PassthroughSubject<Void, Never>()
    let commentCreationTapped = PassthroughSubject<Void, Never>()
    let commentThreadTapped = PassthroughSubject<Void, Never>()
    let clarityDetailsTapped = PassthroughSubject<Void, Never>()
    let monetizationTapped = PassthroughSubject<Void, Never>()
    let examplesTapped = PassthroughSubject<Void, Never>()

    private let _openMockArticleScreen = CurrentValueSubject<SDKUIIndependentViewsActionSettings?, Never>(value: nil)
    var openMockArticleScreen: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> {
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

    private let _openMonetizationScreen = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openMonetizationScreen: AnyPublisher<OWPostId, Never> {
        return _openMonetizationScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("UIViews", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension UIViewsViewModel {
    func setupObservers() {
        let postId = dataModel.postId

        let fullConversationTappedModel = fullConversationTapped
            .map {
                let viewType = SDKUIIndependentViewType.conversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let commentCreationTappedModel = commentCreationTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.commentCreation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let commentThreadTappedModel = commentThreadTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.commentThread
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let clarityDetailsTappedModel = clarityDetailsTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.clarityDetails
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let preConversationTappedModel = preConversationTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.preConversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        Publishers.MergeMany(
            fullConversationTappedModel,
            commentCreationTappedModel,
            commentThreadTappedModel,
            clarityDetailsTappedModel,
            preConversationTappedModel)
        .map { $0 } // swiftlint:disable:this array_init
        .bind(to: _openMockArticleScreen)
        .store(in: &cancellables)

        examplesTapped
            .eraseToAnyPublisher()
            .map { postId }
            .bind(to: _openExamplesScreen)
            .store(in: &cancellables)

        monetizationTapped
            .eraseToAnyPublisher()
            .map { postId }
            .bind(to: _openMonetizationScreen)
            .store(in: &cancellables)
    }
}
