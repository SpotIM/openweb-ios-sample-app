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

    init(data: OWCommentRequiredData) {
        commentHeaderVM = OWCommentHeaderViewModel(data: data)
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel(comment: data.comment)
        contentVM = OWCommentContentViewModel(comment: data.comment, lineLimit: data.collapsableTextLineLimit)
        commentEngagementVM = OWCommentEngagementViewModel(comment: data.comment)
        comment = data.comment
        dictateCommentContentVisibility(data: data)
    }

    init() {
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
        comment = OWComment()
    }
}

fileprivate extension OWCommentViewModel {
    func dictateCommentContentVisibility(data: OWCommentRequiredData) {
        guard let commentId = data.comment.id else { return }

        let shouldHide = data.user.isMuted || // muted
            data.comment.deleted || // deleted
            SPUserSessionHolder.session.reportedComments[commentId] != nil // reported

        self._shouldHideCommentContent.onNext(shouldHide)
    }
}
