//
//  OWConversationEmptyStateViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 09/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationEmptyStateViewModelingInputs {
    var isEmpty: PublishSubject<Bool> { get }
    var isReadOnly: PublishSubject<Bool> { get }
}

protocol OWConversationEmptyStateViewModelingOutputs {
    var iconName: Observable<String> { get }
    var text: Observable<String> { get }
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

    fileprivate struct Metrics {
        static let emptyIcon: String = "emptyConversation-icon"
        static let closedAndEmptyIcon: String = "closedAndEmptyConversation-icon"
    }

    var conversationFetched = PublishSubject<SPConversationReadRM>()
    var isReadOnly = PublishSubject<Bool>()
    var isEmpty = PublishSubject<Bool>()
    fileprivate let _contentType = BehaviorSubject<OWConversationContentType?>(value: nil)
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

    lazy var text: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .empty:
                    return OWLocalizationManager.shared.localizedString(key: "Start the conversation and share your thoughts and ideas with the community.")
                case .closedAndEmpty:
                    return OWLocalizationManager.shared.localizedString(key: "This conversation has ended and comments are no longer being accepted.")
                }
            }
            .asObservable()
    }()

    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

fileprivate extension OWConversationEmptyStateViewModel {
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
            guard let self = self else { return }
            self._contentType.onNext(contentType)
        })
        .disposed(by: disposeBag)
    }
}
