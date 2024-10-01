//
//  OWCompactCommentViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWPreConversationCompactContentViewModelingInputs {
    var conversationFetched: PublishSubject<OWConversationReadRM> { get }
    var isReadOnly: PublishSubject<Bool> { get }
    var conversationError: PublishSubject<Bool> { get }
    var tryAgainTap: PublishSubject<Void> { get }
}

protocol OWPreConversationCompactContentViewModelingOutputs {
    var avatarVM: OWAvatarViewModeling { get }
    var contentType: Observable<OWCompactContentType> { get }
    var isSkelatonHidden: Observable<Bool> { get }
    var isCommentHidden: Observable<Bool> { get }
    var text: Observable<String> { get }
    var shouldShowImagePlaceholder: Observable<Bool> { get }
    var tryAgainTapped: Observable<Void> { get }
}

protocol OWPreConversationCompactContentViewModeling {
    var inputs: OWPreConversationCompactContentViewModelingInputs { get }
    var outputs: OWPreConversationCompactContentViewModelingOutputs { get }
}

class OWPreConversationCompactContentViewModel: OWPreConversationCompactContentViewModeling,
                                                OWPreConversationCompactContentViewModelingInputs,
                                                OWPreConversationCompactContentViewModelingOutputs {

    var inputs: OWPreConversationCompactContentViewModelingInputs { return self }
    var outputs: OWPreConversationCompactContentViewModelingOutputs { return self }

    var conversationFetched = PublishSubject<OWConversationReadRM>()
    var isReadOnly = PublishSubject<Bool>()
    var conversationError = PublishSubject<Bool>()
    fileprivate var emptyConversation = PublishSubject<Void>()
    fileprivate var comment = PublishSubject<OWComment>()

    fileprivate let _contentType = BehaviorSubject<OWCompactContentType>(value: .skeleton)
    lazy var contentType: Observable<OWCompactContentType> = {
        return _contentType
            .asObservable()
    }()

    lazy var isSkelatonHidden: Observable<Bool> = {
        contentType
            .map { type in
                if case .skeleton = type {
                    return false
                }
                return true
            }
            .asObservable()
    }()

    lazy var isCommentHidden: Observable<Bool> = {
        contentType
            .map { type in
                if case .comment = type {
                    return false
                }
                return true
            }
            .asObservable()
    }()

    lazy var shouldShowImagePlaceholder: Observable<Bool> = {
        contentType
            .map { type in
                if case .comment(let commentType) = type,
                   case .media = commentType {
                    return true
                }
                return false
            }
    }()

    lazy var text: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .skeleton:
                    return ""
                case .emptyConversation:
                    return OWLocalizationManager.shared.localizedString(key: "EmptyConversation")
                case .closedAndEmpty:
                    return OWLocalizationManager.shared.localizedString(key: "ClosedAndEmptyConversation")
                case .comment(let commentType):
                    switch commentType {
                    case .media:
                        return OWLocalizationManager.shared.localizedString(key: "Image")
                    case .text(let string):
                        return string
                    }
                case .error:
                    return OWLocalizationManager.shared.localizedString(key: "ErrorStateLoadComments")
                }
            }
            .asObservable()
    }()

    var tryAgainTap = PublishSubject<Void>()
    lazy var tryAgainTapped: Observable<Void> = {
        return tryAgainTap
            .asObservable()
    }()

    fileprivate let imageProvider: OWImageProviding
    fileprivate let disposeBag = DisposeBag()
    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.imageProvider = imageProvider
        setupObservers()
    }

    lazy var avatarVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(imageURLProvider: self.imageProvider)
    }()
}

fileprivate extension OWPreConversationCompactContentViewModel {
    func setupObservers() {
        conversationFetched
            .subscribe(onNext: { [weak self] conversationResponse in
                guard let self = self,
                      let responseComments = conversationResponse.conversation?.comments,
                      !responseComments.isEmpty
                else { return }

                let comment = responseComments[0]
                // Set comment
                self.comment.onNext(comment)
                // Set user (avatar)
                guard let user = conversationResponse.conversation?.users?[comment.userId ?? ""] else { return }
                self.avatarVM.inputs.userInput.onNext(user)
            })
            .disposed(by: disposeBag)

        // Set empty & read only if needed
        Observable.combineLatest(conversationFetched, isReadOnly) { conversationResponse, isReadOnly -> OWCompactContentType? in
            guard conversationResponse.conversation?.messagesCount == 0 else { return nil }
            if isReadOnly {
                return .closedAndEmpty
            } else {
                return .emptyConversation
            }
        }
        .unwrap()
        .subscribe(onNext: { [weak self] contentType in
            guard let self = self else { return }
            self._contentType.onNext(contentType)
        })
        .disposed(by: disposeBag)

        // Set comment type
        comment
            .subscribe(onNext: { [weak self] commentData in
                guard let self = self else { return }

                let commentType: OWCompactCommentType = {
                    if let commentText = commentData.text?.text {
                        return .text(string: commentText)
                    }
                    return .media
                }()
                self._contentType.onNext(.comment(type: commentType))
            })
            .disposed(by: disposeBag)

        // Set error
        let showErrorObservable: Observable<OWCompactContentType> = conversationError
            .filter { $0 }
            .voidify()
            .map { .error }

        let showSkeletonObservable: Observable<OWCompactContentType> = tryAgainTapped
            .voidify()
            .map { .skeleton }

        Observable.merge(showErrorObservable, showSkeletonObservable)
                    .bind(to: _contentType)
                    .disposed(by: disposeBag)
    }
}
