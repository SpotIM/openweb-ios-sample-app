//
//  MonetizationFlowsViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 15/01/2025.
//

import Foundation
import OpenWebSDK
import RxSwift

protocol MonetizationFlowsViewModelingInputs {
    var singleAdExampleTapped: PublishSubject<Void> { get }
    var preConversationWithAdTapped: PublishSubject<PresentationalModeCompact> { get }
}

protocol MonetizationFlowsViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: Observable<OWPostId> { get }
    var openPreconversationWithAdExample: Observable<SDKUIFlowActionSettings> { get }
}

protocol MonetizationFlowsViewModeling {
    var inputs: MonetizationFlowsViewModelingInputs { get }
    var outputs: MonetizationFlowsViewModelingOutputs { get }
}

class MonetizationFlowsViewModel: MonetizationFlowsViewModeling, MonetizationFlowsViewModelingOutputs, MonetizationFlowsViewModelingInputs {

    var inputs: MonetizationFlowsViewModelingInputs { return self }
    var outputs: MonetizationFlowsViewModelingOutputs { return self }

    private let postId: OWPostId
    private let disposeBag = DisposeBag()

    let singleAdExampleTapped = PublishSubject<Void>()
    let preConversationWithAdTapped = PublishSubject<PresentationalModeCompact>()

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

private extension MonetizationFlowsViewModel {
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
