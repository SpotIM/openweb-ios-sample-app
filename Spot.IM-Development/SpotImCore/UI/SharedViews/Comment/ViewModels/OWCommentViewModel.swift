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
    var commentLabelVM: OWCommentLabelViewModeling { get }
    var contentVM: OWCommentContentViewModeling { get }
    var commentEngagementVM: OWCommentEngagementViewModeling { get }
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
    var commentLabelVM: OWCommentLabelViewModeling
    var contentVM: OWCommentContentViewModeling
    var commentEngagementVM: OWCommentEngagementViewModeling
    
    init(data: OWCommentRequiredData) {
        commentUserVM = OWCommentUserViewModel(user: data.user, imageProvider: nil)
        commentHeaderVM = OWCommentHeaderViewModel(user: data.user, replyTo: data.replyToUser, model: data.comment)
        commentLabelVM = OWCommentLabelViewModel(comment: data.comment)
        contentVM = OWCommentContentViewModel(comment: data.comment)
        commentEngagementVM = OWCommentEngagementViewModel(replies: data.comment.repliesCount ?? 0, rank: data.comment.rank ?? SPComment.Rank())
    }
    
    init() {
        commentUserVM = OWCommentUserViewModel(user: nil, imageProvider: nil)
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelVM = OWCommentLabelViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
    }
}
