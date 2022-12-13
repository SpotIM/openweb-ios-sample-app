//
//  OWCommentCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCellViewModelingInputs {
    
}

protocol OWCommentCellViewModelingOutputs {
    var commentVM: OWCommentViewModeling { get }
}

protocol OWCommentCellViewModeling: OWCellViewModel {
    var inputs: OWCommentCellViewModelingInputs { get }
    var outputs: OWCommentCellViewModelingOutputs { get }
}

class OWCommentCellViewModel: OWCommentCellViewModeling, OWCommentCellViewModelingInputs, OWCommentCellViewModelingOutputs {
    var inputs: OWCommentCellViewModelingInputs { return self }
    var outputs: OWCommentCellViewModelingOutputs { return self }
    
    fileprivate var comment: SPComment? = nil
    fileprivate var user: SPUser? = nil
    fileprivate var replyTo: SPUser? = nil
    
    var commentVM: OWCommentViewModeling {
        if let comment = comment, let user = user {
            return OWCommentViewModel(comment: comment, user: user, replyTo: replyTo)
        } else {
            return OWCommentViewModel()
        }
    }
    
    init(comment: SPComment, user: SPUser?, replyTo: SPUser?) {
        self.comment = comment
        self.user = user
        self.replyTo = replyTo
    }
    
    init() {}
}

extension OWCommentCellViewModel {
    static func stub() -> OWCommentCellViewModeling {
        return OWCommentCellViewModel()
    }
}
