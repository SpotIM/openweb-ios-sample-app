//
//  OWCommentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentViewModelingInputs {
    func updateEditedCommentLocally(updatedComment: OWComment)
    func reportCommentLocally()
    func deleteCommentLocally()
    func muteCommentLocally()
}

protocol OWCommentViewModelingOutputs {
    var statusIndicationVM: OWCommentStatusIndicationViewModeling { get }
    var commentActionsVM: OWCommentActionsViewModeling { get }

    var commentHeaderVM: OWCommentHeaderViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var contentVM: OWCommentContentViewModeling { get }
    var commentEngagementVM: OWCommentEngagementViewModeling { get }
    var shouldHideCommentContent: Observable<Bool> { get }

    var comment: OWComment { get }
}

protocol OWCommentViewModeling {
    var inputs: OWCommentViewModelingInputs { get }
    var outputs: OWCommentViewModelingOutputs { get }
}

class OWCommentViewModel: OWCommentViewModeling,
                          OWCommentViewModelingInputs,
                          OWCommentViewModelingOutputs {

    var inputs: OWCommentViewModelingInputs { return self }
    var outputs: OWCommentViewModelingOutputs { return self }

    fileprivate let sharedServiceProvider: OWSharedServicesProviding

    lazy var statusIndicationVM: OWCommentStatusIndicationViewModeling = {
        return OWCommentStatusIndicationViewModel()
    }()

    lazy var commentActionsVM: OWCommentActionsViewModeling = {
        return OWCommentActionsViewModel()
    }()

    var commentHeaderVM: OWCommentHeaderViewModeling
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling
    var contentVM: OWCommentContentViewModeling
    var commentEngagementVM: OWCommentEngagementViewModeling
    var comment: OWComment

    fileprivate let _shouldHideCommentContent = BehaviorSubject<Bool>(value: false)
    var shouldHideCommentContent: Observable<Bool> {
        _shouldHideCommentContent
            .asObservable()
    }

    func reportCommentLocally() {
        self.commentHeaderVM.inputs.shouldReportCommentLocally.onNext(true)
        self._shouldHideCommentContent.onNext(true)
    }

    func deleteCommentLocally() {
        self._shouldHideCommentContent.onNext(true)
        self.commentHeaderVM.inputs.shouldDeleteCommentLocally.onNext(true)
        self.updateDeletedCommentInCommentsService()
    }

    func muteCommentLocally() {
        self._shouldHideCommentContent.onNext(true)
        self.commentHeaderVM.inputs.shouldMuteCommentLocally.onNext(true)
    }

    func updateEditedCommentLocally(updatedComment: OWComment) {
        self.comment = updatedComment
        self.contentVM.inputs.updateEditedCommentLocally(updatedComment)
        self.commentLabelsContainerVM.inputs.updateEditedCommentLocally(updatedComment)
    }

    init(data: OWCommentRequiredData, sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentHeaderVM = OWCommentHeaderViewModel(data: data)
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel(comment: data.comment, section: data.section)
        contentVM = OWCommentContentViewModel(comment: data.comment, lineLimit: data.collapsableTextLineLimit)
        commentEngagementVM = OWCommentEngagementViewModel(comment: data.comment)
        comment = data.comment
        dictateCommentContentVisibility(data: data)
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
        comment = OWComment()
    }
}

fileprivate extension OWCommentViewModel {
    func dictateCommentContentVisibility(data: OWCommentRequiredData) {
        let shouldHide = data.user.isMuted || // muted
            data.comment.deleted || // deleted
            data.comment.reported // reported

        self._shouldHideCommentContent.onNext(shouldHide)
    }

    func updateDeletedCommentInCommentsService() {
        guard let postId = OWManager.manager.postId,
              let commentId = comment.id,
              var comment = self.sharedServiceProvider.commentsService().get(commentId: commentId, postId: postId)
        else { return }

        comment.setIsDeleted(true)
        self.sharedServiceProvider
            .commentsService()
            .set(comments: [comment], postId: postId)
    }
}
