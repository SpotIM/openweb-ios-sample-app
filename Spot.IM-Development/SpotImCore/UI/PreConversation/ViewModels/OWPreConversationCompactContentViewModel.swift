//
//  OWCompactCommentViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWPreConversationCompactContentViewModelingInputs {
    var conversationFetched: PublishSubject<SPConversationReadRM> { get }
}

protocol OWPreConversationCompactContentViewModelingOutputs {
    var avatarVM: OWAvatarViewModeling { get }
    var contentType: Observable<OWCompactContentType> { get }
    var isSkelatonHidden: Observable<Bool> { get }
    var isCommentHidden: Observable<Bool> { get }
    var text: Observable<String> { get }
    var shouldShowImagePlaceholder: Observable<Bool> { get }
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

    var conversationFetched = PublishSubject<SPConversationReadRM>()
    fileprivate var emptyConversation = PublishSubject<Void>()
    fileprivate var comment = PublishSubject<SPComment>()

    fileprivate let _contentType = BehaviorSubject<OWCompactContentType>(value: .skelaton)
    lazy var contentType: Observable<OWCompactContentType> = {
        return _contentType
            .asObservable()
    }()

    lazy var isSkelatonHidden: Observable<Bool> = {
        contentType
            .map { type in
                if case .skelaton = type {
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
                case .skelaton:
                    return ""
                case .emptyConversation:
                    return "empty placeolder TODO" // TODO: String
                case .closedAndEmpty:
                    return "closedAndEmpty TODO" // TODO: String
                case .comment(let commentType):
                    switch commentType {
                    case .media:
                        return "Image" // TODO: String
                    case .text(let string):
                        return string
                    }
                }
            }
            .asObservable()
    }()

    fileprivate let imageProvider: OWImageProviding
    fileprivate let disposeBag = DisposeBag()
    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.imageProvider = imageProvider
        setupObservers()
    }

    lazy var avatarVM: OWAvatarViewModeling = {
        return OWAvatarViewModelV2(imageURLProvider: self.imageProvider)
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
                self.avatarVM.inputs.configureUser(user: user)
            })
            .disposed(by: disposeBag)

        // Set empty if needed
        // TODO: support empty + read only
        conversationFetched
            .subscribe(onNext: { [weak self] conversationResponse in
                guard let self = self,
                      conversationResponse.conversation?.messagesCount == 0 else { return }
                if conversationResponse.conversation?.readOnly == true {
                    self._contentType.onNext(.closedAndEmpty)
                } else {
                    self._contentType.onNext(.emptyConversation)
                }
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
    }
}

enum OWCompactCommentType {
    case text(string: String)
    case media
}

enum OWCompactContentType {
    case comment(type: OWCompactCommentType)
    case emptyConversation
    case closedAndEmpty
    case skelaton
}

