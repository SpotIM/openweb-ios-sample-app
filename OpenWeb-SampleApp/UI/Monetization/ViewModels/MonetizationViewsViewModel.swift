//
//  MonetizationViewsViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Foundation
import OpenWebSDK
import RxSwift

protocol MonetizationViewsViewModelingInputs {
    var singleAdExampleTapped: PublishSubject<Void> { get }
    var preConversationWithAdTapped: PublishSubject<Void> { get }
}

protocol MonetizationViewsViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: Observable<OWPostId> { get }
    var openPreconversationWithAdExample: Observable<SDKUIIndependentViewsActionSettings> { get }
}

protocol MonetizationViewsViewModeling {
    var inputs: MonetizationViewsViewModelingInputs { get }
    var outputs: MonetizationViewsViewModelingOutputs { get }
}

class MonetizationViewsViewModel: MonetizationViewsViewModeling, MonetizationViewsViewModelingOutputs, MonetizationViewsViewModelingInputs {
    var inputs: MonetizationViewsViewModelingInputs { return self }
    var outputs: MonetizationViewsViewModelingOutputs { return self }

    private let postId: OWPostId
    private let disposeBag = DisposeBag()

    let singleAdExampleTapped = PublishSubject<Void>()
    let preConversationWithAdTapped = PublishSubject<Void>()

    private let _openSingleAdExample = BehaviorSubject<OWPostId?>(value: nil)
    var openSingleAdExample: Observable<OWPostId> {
        return _openSingleAdExample
            .unwrap()
            .asObservable()
    }

    private let _openPreconversationWithAdExample = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    var openPreconversationWithAdExample: Observable<SDKUIIndependentViewsActionSettings> {
        return _openPreconversationWithAdExample
            .unwrap()
            .asObservable()
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
            .asObservable()
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openSingleAdExample)
            .disposed(by: disposeBag)

        preConversationWithAdTapped
            .asObservable()
            .map { [weak self] _ -> SDKUIIndependentViewsActionSettings? in
                guard let self else { return nil }
                let action = SDKUIIndependentViewType.preConversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: action)
                return model
            }
            .unwrap()
            .bind(to: _openPreconversationWithAdExample)
            .disposed(by: disposeBag)
    }
}
