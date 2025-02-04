//
//  MonetizationFlowsViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

import Foundation
import OpenWebSDK
import Combine

protocol MonetizationFlowsViewModelingInputs {
    var singleAdExampleTapped: PassthroughSubject<Void, Never> { get }
    var preConversationWithAdTapped: PassthroughSubject<PresentationalModeCompact, Never> { get }
}

protocol MonetizationFlowsViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: AnyPublisher<OWPostId, Never> { get }
    var openPreconversationWithAdExample: AnyPublisher<SDKUIFlowActionSettings, Never> { get }
}

protocol MonetizationFlowsViewModeling {
    var inputs: MonetizationFlowsViewModelingInputs { get }
    var outputs: MonetizationFlowsViewModelingOutputs { get }
}

class MonetizationFlowsViewModel: MonetizationFlowsViewModeling, MonetizationFlowsViewModelingOutputs, MonetizationFlowsViewModelingInputs {

    var inputs: MonetizationFlowsViewModelingInputs { return self }
    var outputs: MonetizationFlowsViewModelingOutputs { return self }

    private let postId: OWPostId
    private var cancellables = Set<AnyCancellable>()

    let singleAdExampleTapped = PassthroughSubject<Void, Never>()
    let preConversationWithAdTapped = PassthroughSubject<PresentationalModeCompact, Never>()

    private let _openSingleAdExample = CurrentValueSubject<OWPostId?, Never>(nil)
    var openSingleAdExample: AnyPublisher<OWPostId, Never> {
        return _openSingleAdExample
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _openPreconversationWithAdExample = CurrentValueSubject<SDKUIFlowActionSettings?, Never>(nil)
    var openPreconversationWithAdExample: AnyPublisher<SDKUIFlowActionSettings, Never> {
        return _openPreconversationWithAdExample
            .unwrap()
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("Monetization", comment: "")
    }()

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

private extension MonetizationFlowsViewModel {
    func setupObservers() {
        singleAdExampleTapped
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openSingleAdExample)
            .store(in: &cancellables)

        preConversationWithAdTapped
            .map { [weak self] mode -> SDKUIFlowActionSettings? in
                guard let self else { return nil }
                let action = SDKUIFlowActionType.preConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }
            .unwrap()
            .bind(to: _openPreconversationWithAdExample)
            .store(in: &cancellables)
    }
}
