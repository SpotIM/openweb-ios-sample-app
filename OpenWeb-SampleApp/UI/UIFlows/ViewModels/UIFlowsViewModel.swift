//
//  UIFlowsViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 04/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol UIFlowsViewModelingInputs {
    var preConversationTapped: PassthroughSubject<PresentationalModeCompact, Never> { get }
    var fullConversationTapped: PassthroughSubject<PresentationalModeCompact, Never> { get }
    var commentCreationTapped: PassthroughSubject<PresentationalModeCompact, Never> { get }
    var commentThreadTapped: PassthroughSubject<PresentationalModeCompact, Never> { get }
    var monetizationTapped: PassthroughSubject<Void, Never> { get }
}

protocol UIFlowsViewModelingOutputs {
    var title: String { get }
    // Usually the coordinator layer will handle this, however current architecture is missing a coordinator layer until we will do a propper refactor
    var openMockArticleScreen: AnyPublisher<SDKUIFlowActionSettings, Never> { get }
    var openMonetizationScreen: AnyPublisher<OWPostId, Never> { get }
    var presentStyle: OWModalPresentationStyle { get }
}

protocol UIFlowsViewModeling {
    var inputs: UIFlowsViewModelingInputs { get }
    var outputs: UIFlowsViewModelingOutputs { get }
}

class UIFlowsViewModel: UIFlowsViewModeling, UIFlowsViewModelingOutputs, UIFlowsViewModelingInputs {
    var inputs: UIFlowsViewModelingInputs { return self }
    var outputs: UIFlowsViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    private var cancellables = Set<AnyCancellable>()

    let preConversationTapped = PassthroughSubject<PresentationalModeCompact, Never>()
    let fullConversationTapped = PassthroughSubject<PresentationalModeCompact, Never>()
    let commentCreationTapped = PassthroughSubject<PresentationalModeCompact, Never>()
    let commentThreadTapped = PassthroughSubject<PresentationalModeCompact, Never>()
    let monetizationTapped = PassthroughSubject<Void, Never>()

    private let _openMockArticleScreen = CurrentValueSubject<SDKUIFlowActionSettings?, Never>(value: nil)
    var openMockArticleScreen: AnyPublisher<SDKUIFlowActionSettings, Never> {
        return _openMockArticleScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    var presentStyle: OWModalPresentationStyle {
        return OWModalPresentationStyle.presentationStyle(fromIndex: UserDefaultsProvider.shared.get(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.default.index))
    }

    private let _openMonetizationScreen = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openMonetizationScreen: AnyPublisher<OWPostId, Never> {
        return _openMonetizationScreen
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("UIFlows", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension UIFlowsViewModel {

    func setupObservers() {
        let postId = dataModel.postId

        let fullConversationTappedModel = fullConversationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.fullConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let commentCreationTappedModel = commentCreationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.commentCreation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let commentThreadTappedModel = commentThreadTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.commentThread(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        let preConversationTappedModel = preConversationTapped
            .map { mode -> SDKUIFlowActionSettings in
                let action = SDKUIFlowActionType.preConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }

        Publishers.MergeMany(fullConversationTappedModel, commentCreationTappedModel, commentThreadTappedModel, preConversationTappedModel)
            .map { $0 } // swiftlint:disable:this array_init
            .bind(to: _openMockArticleScreen)
            .store(in: &cancellables)

        monetizationTapped
            .eraseToAnyPublisher()
            .map { postId }
            .bind(to: _openMonetizationScreen)
            .store(in: &cancellables)
    }
}
