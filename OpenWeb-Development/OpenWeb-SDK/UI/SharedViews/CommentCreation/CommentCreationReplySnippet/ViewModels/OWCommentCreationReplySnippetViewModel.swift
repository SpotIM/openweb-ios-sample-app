//
//  OWCommentCreationReplySnippetViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 16/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationReplySnippetViewModelingInputs {
}

protocol OWCommentCreationReplySnippetViewModelingOutputs {
    var replySnippetText: Observable<String> { get }
    var showSeparator: Observable<Bool> { get }
}

protocol OWCommentCreationReplySnippetViewModeling {
    var inputs: OWCommentCreationReplySnippetViewModelingInputs { get }
    var outputs: OWCommentCreationReplySnippetViewModelingOutputs { get }
}

class OWCommentCreationReplySnippetViewModel: OWCommentCreationReplySnippetViewModeling,
                                              OWCommentCreationReplySnippetViewModelingInputs,
                                              OWCommentCreationReplySnippetViewModelingOutputs {

    var inputs: OWCommentCreationReplySnippetViewModelingInputs { return self }
    var outputs: OWCommentCreationReplySnippetViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationType: OWCommentCreationTypeInternal
    fileprivate let shouldShowSeparator: Bool

    var replySnippetText: Observable<String> {
        guard let postId = OWManager.manager.postId else { return Observable.empty() }
        var replyToComment: OWComment? = nil
        switch commentCreationType {
        case .edit(let comment):
            if let parentId = comment.parentId,
               var parentComment = servicesProvider.commentsService().get(commentId: parentId, postId: postId) {
                // Adding here the display names of mentions within theparent comment text
                OWUserMentionHelper.createUserMentions(from: &parentComment)
                replyToComment = parentComment
            }
        case .replyToComment(let originComment):
            replyToComment = originComment
        default:
            break
        }
        if let originCommentText = replyToComment?.text?.text {
            return Observable.just(originCommentText)
        } else {
            return Observable.empty()
        }
    }

    var showSeparator: Observable<Bool> {
        Observable.just(shouldShowSeparator)
    }

    init(commentCreationType: OWCommentCreationTypeInternal,
         shouldShowSeparator: Bool = true,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationType = commentCreationType
        self.shouldShowSeparator = shouldShowSeparator
        setupObservers()
    }
}

fileprivate extension OWCommentCreationReplySnippetViewModel {
    func setupObservers() {

    }
}

