//
//  OWCommentThreadExpandCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadExpandCellViewModelingInputs {

}

protocol OWCommentThreadExpandCellViewModelingOutputs {
    var id: String { get }
    var commentPresentationData: OWCommentPresentationData { get }
    var commentActionsVM: OWCommentThreadActionsViewModel { get }
    var depth: Int { get }
}

protocol OWCommentThreadExpandCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadExpandCellViewModelingInputs { get }
    var outputs: OWCommentThreadExpandCellViewModelingOutputs { get }
}

class OWCommentThreadExpandCellViewModel: OWCommentThreadExpandCellViewModeling, OWCommentThreadExpandCellViewModelingInputs, OWCommentThreadExpandCellViewModelingOutputs {
    var inputs: OWCommentThreadExpandCellViewModelingInputs { return self }
    var outputs: OWCommentThreadExpandCellViewModelingOutputs { return self }

    var id: String = UUID().uuidString

    var depth: Int = 0

    let commentPresentationData: OWCommentPresentationData

    let commentActionsVM: OWCommentThreadActionsViewModel

    init(data: OWCommentPresentationData, depth: Int = 0) {
        self.commentPresentationData = data
        self.depth = depth

        let visibleRepliesCount = commentPresentationData.repliesThreadState.getVisibleRepliesCount()
        let totalRepliesCount = commentPresentationData.totalRepliesCount

        let extendedRepliesCount = min(visibleRepliesCount + 5, totalRepliesCount)

        let commentThreadActionType: OWCommentThreadActionType
        if (visibleRepliesCount == 0 && totalRepliesCount < 5) {
            commentThreadActionType = .viewMoreReplies(count: extendedRepliesCount)
        } else {
            commentThreadActionType = .viewMoreRepliesRange(from: extendedRepliesCount, to: totalRepliesCount)
        }
        commentActionsVM = OWCommentThreadActionsViewModel(with: commentThreadActionType)
    }

    init() {
        self.commentPresentationData = OWCommentPresentationData(id: "", totalRepliesCount: 0, repliesOffset: 0)

        commentActionsVM = OWCommentThreadActionsViewModel(with: .collapseThread)
    }
}

extension OWCommentThreadExpandCellViewModel {
    static func stub() -> OWCommentThreadExpandCellViewModeling {
        return OWCommentThreadExpandCellViewModel()
    }
}
