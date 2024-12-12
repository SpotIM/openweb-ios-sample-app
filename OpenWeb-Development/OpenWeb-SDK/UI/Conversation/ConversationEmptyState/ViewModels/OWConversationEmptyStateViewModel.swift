//
//  OWConversationEmptyStateViewModel.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 09/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWConversationEmptyStateViewModelingInputs {
    var isEmpty: PublishSubject<Bool> { get }
    var isReadOnly: PublishSubject<Bool> { get }
    var triggerCustomizeIconImageViewUI: PublishSubject<UIImageView> { get }
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
}

protocol OWConversationEmptyStateViewModelingOutputs {
    var iconName: Observable<String> { get }
    var iconIdentifier: Observable<String> { get }
    var text: Observable<String> { get }
    var customizeIconImageViewUI: Observable<UIImageView> { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
}

protocol OWConversationEmptyStateViewModeling {
    var inputs: OWConversationEmptyStateViewModelingInputs { get }
    var outputs: OWConversationEmptyStateViewModelingOutputs { get }
}

class OWConversationEmptyStateViewModel: OWConversationEmptyStateViewModeling,
                                         OWConversationEmptyStateViewModelingInputs,
                                         OWConversationEmptyStateViewModelingOutputs {
    var inputs: OWConversationEmptyStateViewModelingInputs { return self }
    var outputs: OWConversationEmptyStateViewModelingOutputs { return self }

    private struct Metrics {
        static let emptyIcon: String = "emptyConversation-icon"
        static let closedAndEmptyIcon: String = "closedAndEmptyConversation-icon"
        static let emptyIconIdentifier = "empty_state_view_empty_icon_id"
        static let closedAndEmptyIconIdentifier = "empty_state_view_closed_and_empty_icon_id"
    }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    private let _triggerCustomizeIconImageViewUI = BehaviorSubject<UIImageView?>(value: nil)
    private let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeIconImageViewUI = PublishSubject<UIImageView>()
    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()

    var customizeIconImageViewUI: Observable<UIImageView> {
        return _triggerCustomizeIconImageViewUI
            .unwrap()
            .asObservable()
    }

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var conversationFetched = PublishSubject<SPConversationReadRM>()
    var isReadOnly = PublishSubject<Bool>()
    var isEmpty = PublishSubject<Bool>()
    private let _contentType = BehaviorSubject<OWConversationContentType?>(value: nil)
    lazy var contentType: Observable<OWConversationContentType> = {
        return _contentType
            .unwrap()
            .asObservable()
    }()

    lazy var iconName: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .empty:
                    return Metrics.emptyIcon
                case .closedAndEmpty:
                    return Metrics.closedAndEmptyIcon
                }
            }
            .asObservable()
    }()

    lazy var iconIdentifier: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .empty:
                    return Metrics.emptyIconIdentifier
                case .closedAndEmpty:
                    return Metrics.closedAndEmptyIconIdentifier
                }
            }
            .asObservable()
    }()

    lazy var text: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .empty:
                    return OWLocalize.string("EmptyConversation")
                case .closedAndEmpty:
                    return OWLocalize.string("ClosedAndEmptyConversation")
                }
            }
            .asObservable()
    }()

    private let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

private extension OWConversationEmptyStateViewModel {
    func setupObservers() {
        Observable.combineLatest(isReadOnly, isEmpty) { isReadOnly, isEmpty -> OWConversationContentType? in
            if isEmpty {
                return isReadOnly ? .closedAndEmpty : .empty
            } else {
                return nil
            }
        }
        .unwrap()
        .subscribe(onNext: { [weak self] contentType in
            guard let self else { return }
            self._contentType.onNext(contentType)
        })
        .disposed(by: disposeBag)

        triggerCustomizeTitleLabelUI
            .flatMapLatest { [weak self] label -> Observable<UILabel> in
                guard let self else { return .empty() }
                return self.text
                    .map { _ in return label }
            }
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeIconImageViewUI
            .bind(to: _triggerCustomizeIconImageViewUI)
            .disposed(by: disposeBag)
    }
}
