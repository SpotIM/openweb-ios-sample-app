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
    var socialMonetizationExampleTapped: PublishSubject<Void> { get }
    var preConversationExampleTapped: PublishSubject<Void> { get }
}

protocol MonetizationViewViewModelingOutputs {
    var title: String { get }
    var openSocialMonetizationExample: Observable<OWPostId> { get }
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

    let socialMonetizationExampleTapped = PublishSubject<Void>()
    let preConversationExampleTapped = PublishSubject<Void>()

    private let _openSocialMonetizationExample = BehaviorSubject<OWPostId?>(value: nil)
    var openSocialMonetizationExample: Observable<OWPostId> {
        return _openSocialMonetizationExample
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
        socialMonetizationExampleTapped
            .asObservable()
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openSocialMonetizationExample)
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
