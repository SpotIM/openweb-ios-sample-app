//
//  OWCommentThreadCollapseCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadCollapseCellViewModelingInputs {

}

protocol OWCommentThreadCollapseCellViewModelingOutputs {
    var id: String { get }
    var commentPresentationData: OWCommentPresentationData { get }
    var commentActionsVM: OWCommentThreadActionsViewModel { get }
}

protocol OWCommentThreadCollapseCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadCollapseCellViewModelingInputs { get }
    var outputs: OWCommentThreadCollapseCellViewModelingOutputs { get }
}

class OWCommentThreadCollapseCellViewModel: OWCommentThreadCollapseCellViewModeling, OWCommentThreadCollapseCellViewModelingInputs, OWCommentThreadCollapseCellViewModelingOutputs {
    var inputs: OWCommentThreadCollapseCellViewModelingInputs { return self }
    var outputs: OWCommentThreadCollapseCellViewModelingOutputs { return self }

    var id: String = UUID().uuidString

    let commentPresentationData: OWCommentPresentationData

    let commentActionsVM: OWCommentThreadActionsViewModel

    init(data: OWCommentPresentationData) {
        self.commentPresentationData = data
        commentActionsVM = OWCommentThreadActionsViewModel(with: .collapseThread)
    }

    init() {
        self.commentPresentationData = OWCommentPresentationData(id: "", totalRepliesCount: 0, repliesOffset: 0)
        commentActionsVM = OWCommentThreadActionsViewModel(with: .collapseThread)
    }
}

extension OWCommentThreadCollapseCellViewModel {
    static func stub() -> OWCommentThreadCollapseCellViewModeling {
        return OWCommentThreadCollapseCellViewModel()
    }
}
