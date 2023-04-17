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
    var commentUserVM: OWCommentUserViewModeling { get }
    var statusIndicationVM: OWCommentStatusIndicationViewModeling { get }
    var commentActionsVM: OWCommentActionsViewModeling { get }

    var commentHeaderVM: OWCommentHeaderViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var contentVM: OWCommentContentViewModeling { get }
    var commentEngagementVM: OWCommentEngagementViewModeling { get }

    var comment: SPComment { get }
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

    var commentUserVM: OWCommentUserViewModeling

    var statusIndicationVM: OWCommentStatusIndicationViewModeling {
        return OWCommentStatusIndicationViewModel()
    }

    var commentActionsVM: OWCommentActionsViewModeling {
        return OWCommentActionsViewModel()
    }

    var commentHeaderVM: OWCommentHeaderViewModeling
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling
    var contentVM: OWCommentContentViewModeling
    var commentEngagementVM: OWCommentEngagementViewModeling
    var comment: SPComment

    init(data: OWCommentRequiredData) {
        commentUserVM = OWCommentUserViewModel(user: data.user, imageProvider: nil)
        commentHeaderVM = OWCommentHeaderViewModel(data: data)
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel(comment: data.comment)
        contentVM = OWCommentContentViewModel(comment: data.comment, lineLimit: data.collapsableTextLineLimit)
        commentEngagementVM = OWCommentEngagementViewModel(replies: data.comment.repliesCount ?? 0, rank: data.comment.rank ?? SPComment.Rank(), commentId: data.comment.id ?? "")
        comment = data.comment
    }

    init() {
        commentUserVM = OWCommentUserViewModel(user: nil, imageProvider: nil)
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
        comment = SPComment()
    }
}
