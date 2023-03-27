//
//  OWCommentThreadActionsViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentThreadActionType {
    case collapseThread
    case viewReplies(repliesCount: Int, totalRepliesCount: Int)
}

protocol OWCommentThreadActionsViewModelingInputs {

}

protocol OWCommentThreadActionsViewModelingOutputs {

}

protocol OWCommentThreadActionsViewModeling {
    var inputs: OWCommentThreadActionsViewModelingInputs { get }
    var outputs: OWCommentThreadActionsViewModelingOutputs { get }
}

class OWCommentThreadActionsViewModel: OWCommentThreadActionsViewModeling, OWCommentThreadActionsViewModelingInputs, OWCommentThreadActionsViewModelingOutputs {
    var inputs: OWCommentThreadActionsViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsViewModelingOutputs { return self }
}
