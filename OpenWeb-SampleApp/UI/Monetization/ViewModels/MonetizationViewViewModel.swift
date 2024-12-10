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
    var preConversationExampleTapped: PublishSubject<Void> { get }
}

protocol MonetizationViewViewModelingOutputs {
    var title: String { get }
    var openSingleAdExample: Observable<OWPostId> { get }
    var openPreConversationExample: Observable<OWPostId> { get }
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
    let preConversationExampleTapped = PublishSubject<Void>()

    private let _openSingleAdExample = BehaviorSubject<OWPostId?>(value: nil)
    var openSingleAdExample: Observable<OWPostId> {
        return _openSingleAdExample
            .unwrap()
            .asObservable()
    }

    private let _openPreConversationExample = BehaviorSubject<OWPostId?>(value: nil)
    var openPreConversationExample: Observable<OWPostId> {
        return _openPreConversationExample
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

        preConversationExampleTapped
            .asObservable()
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openPreConversationExample)
            .disposed(by: disposeBag)
    }
}
