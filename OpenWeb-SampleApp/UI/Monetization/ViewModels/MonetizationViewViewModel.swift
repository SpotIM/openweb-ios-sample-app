//
//  MonetizationViewViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import Foundation
import OpenWebSDK
import RxSwift

protocol MonetizationViewViewModelingInputs {
    var singleAdExampleTapped: PublishSubject<Void> { get }
    var preConversationTapped: PublishSubject<PresentationalModeCompact> { get }
}

protocol MonetizationViewViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: Observable<OWPostId> { get }
    var openPreconversationWithAdExample: Observable<SDKUIFlowActionSettings> { get }
}

protocol MonetizationViewViewModeling {
    var inputs: MonetizationViewViewModelingInputs { get }
    var outputs: MonetizationViewViewModelingOutputs { get }
}

class MonetizationViewViewModel: MonetizationViewViewModeling, MonetizationViewViewModelingOutputs, MonetizationViewViewModelingInputs {
    var inputs: MonetizationViewViewModelingInputs { return self }
    var outputs: MonetizationViewViewModelingOutputs { return self }

    private let postId: OWPostId
    private let disposeBag = DisposeBag()

    let singleAdExampleTapped = PublishSubject<Void>()
    let preConversationTapped = PublishSubject<PresentationalModeCompact>()

    private let _openSingleAdExample = BehaviorSubject<OWPostId?>(value: nil)
    var openSingleAdExample: Observable<OWPostId> {
        return _openSingleAdExample
            .unwrap()
            .asObservable()
    }

    private let _openPreconversationWithAdExample = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    var openPreconversationWithAdExample: Observable<SDKUIFlowActionSettings> {
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

private extension MonetizationViewViewModel {
    func setupObservers() {
        singleAdExampleTapped
            .asObservable()
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openSingleAdExample)
            .disposed(by: disposeBag)

        preConversationTapped
            .asObservable()
            .map { [weak self] mode -> SDKUIFlowActionSettings? in
                guard let self else { return nil }
                let action = SDKUIFlowActionType.preConversation(presentationalMode: mode)
                let model = SDKUIFlowActionSettings(postId: postId, actionType: action)
                return model
            }
            .unwrap()
            .bind(to: _openPreconversationWithAdExample)
            .disposed(by: disposeBag)
    }
}
