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
    var contentVM: OWCommentContentViewModeling { get }
    var statusIndicationVM: OWCommentStatusIndicationViewModeling { get }
    var commentActionsVM: OWCommentActionsViewModeling { get }
    
    var commentHeaderVM: OWCommentHeaderViewModeling? { get }
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
    
    var commentUserVM: OWCommentUserViewModeling// {
//        return OWCommentUserViewModel(user: nil, imageProvider: nil)
//    }
    
    var contentVM: OWCommentContentViewModeling {
        return OWCommentContentViewModel()
    }
    
    var statusIndicationVM: OWCommentStatusIndicationViewModeling {
        return OWCommentStatusIndicationViewModel()
    }
    
    var commentActionsVM: OWCommentActionsViewModeling {
        return OWCommentActionsViewModel()
    }
    
    var commentHeaderVM: OWCommentHeaderViewModeling? = nil // TODO!!! should not be optional
    
    init(comment: SPComment, user: SPUser) {
        commentUserVM = OWCommentUserViewModel(user: user, imageProvider: nil)
        commentHeaderVM = OWCommentHeaderViewModel(user: user, model: comment)
    }
    
    // TODO: DELETE!
    init() {
        commentUserVM = OWCommentUserViewModel(user: nil, imageProvider: nil)
    }
}
