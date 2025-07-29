//
//  MonetizationViewsViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Foundation
import OpenWebSDK
import Combine

protocol MonetizationViewsViewModelingInputs {
    var singleAdExampleTapped: PassthroughSubject<Void, Never> { get }
    var preConversationWithAdTapped: PassthroughSubject<Void, Never> { get }
}

protocol MonetizationViewsViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: AnyPublisher<OWPostId, Never> { get }
    var openPreconversationWithAdExample: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> { get }
}

protocol MonetizationViewsViewModeling {
    var inputs: MonetizationViewsViewModelingInputs { get }
    var outputs: MonetizationViewsViewModelingOutputs { get }
}

class MonetizationViewsViewModel: MonetizationViewsViewModeling, MonetizationViewsViewModelingOutputs, MonetizationViewsViewModelingInputs {
    var inputs: MonetizationViewsViewModelingInputs { return self }
    var outputs: MonetizationViewsViewModelingOutputs { return self }

    private let postId: OWPostId
    private var cancellables = Set<AnyCancellable>()

    let singleAdExampleTapped = PassthroughSubject<Void, Never>()
    let preConversationWithAdTapped = PassthroughSubject<Void, Never>()

    private let _openSingleAdExample = CurrentValueSubject<OWPostId?, Never>(value: nil)
    var openSingleAdExample: AnyPublisher<OWPostId, Never> {
        return _openSingleAdExample
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _openPreconversationWithAdExample = CurrentValueSubject<SDKUIIndependentViewsActionSettings?, Never>(value: nil)
    var openPreconversationWithAdExample: AnyPublisher<SDKUIIndependentViewsActionSettings, Never> {
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

private extension MonetizationViewsViewModel {
    func setupObservers() {
        singleAdExampleTapped
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openSingleAdExample)
            .store(in: &cancellables)

        preConversationWithAdTapped
            .map { [weak self] _ -> SDKUIIndependentViewsActionSettings? in
                guard let self else { return nil }
                let action = SDKUIIndependentViewType.preConversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: action)
                return model
            }
            .unwrap()
            .bind(to: _openPreconversationWithAdExample)
            .store(in: &cancellables)
    }
}
