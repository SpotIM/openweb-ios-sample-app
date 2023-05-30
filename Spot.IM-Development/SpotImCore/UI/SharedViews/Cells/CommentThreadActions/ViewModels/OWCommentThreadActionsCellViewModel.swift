//
//  OWCommentThreadActionsCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadActionsCellViewModelingInputs {

}

protocol OWCommentThreadActionsCellViewModelingOutputs {
    var id: String { get }
    var mode: OWCommentThreadActionsCellMode { get }
    var commentPresentationData: OWCommentPresentationData { get }
    var commentActionsVM: OWCommentThreadActionsViewModel { get }
    var depth: Int { get }
}

protocol OWCommentThreadActionsCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadActionsCellViewModelingInputs { get }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { get }
}

enum OWCommentThreadActionsCellMode {
    case collapse
    case expand
}

class OWCommentThreadActionsCellViewModel: OWCommentThreadActionsCellViewModeling, OWCommentThreadActionsCellViewModelingInputs, OWCommentThreadActionsCellViewModelingOutputs {
    fileprivate struct Metrics {
        static let expandCommentsCount: Int = 5
    }

    var inputs: OWCommentThreadActionsCellViewModelingInputs { return self }
    var outputs: OWCommentThreadActionsCellViewModelingOutputs { return self }

    var id: String = UUID().uuidString

    var depth: Int = 0

    let commentPresentationData: OWCommentPresentationData

    var mode: OWCommentThreadActionsCellMode = .collapse

    var commentActionsVM: OWCommentThreadActionsViewModel = OWCommentThreadActionsViewModel(with: .collapseThread)

    init(id: String = UUID().uuidString, data: OWCommentPresentationData, mode: OWCommentThreadActionsCellMode = .collapse, depth: Int = 0) {
        self.id = id
        self.commentPresentationData = data
        self.depth = depth
        self.mode = mode

        let commentThreadActionType: OWCommentThreadActionType = mode == .collapse ? .collapseThread : self.getCommentThreadActionTypeForExpand()

        self.commentActionsVM = OWCommentThreadActionsViewModel(with: commentThreadActionType)
    }

    init() {
        self.commentPresentationData = OWCommentPresentationData(
            id: "",
            repliesIds: [],
            totalRepliesCount: 0,
            repliesOffset: 0,
            repliesPresentation: []
        )
    }
}

fileprivate extension OWCommentThreadActionsCellViewModel {
    func getCommentThreadActionTypeForExpand() -> OWCommentThreadActionType {
        let visibleRepliesCount = commentPresentationData.repliesPresentation.count
        let totalRepliesCount = commentPresentationData.totalRepliesCount

        let extendedRepliesCount = min(visibleRepliesCount + Metrics.expandCommentsCount, totalRepliesCount)

        let commentThreadActionType: OWCommentThreadActionType
        if (visibleRepliesCount == 0 && totalRepliesCount < Metrics.expandCommentsCount) {
            commentThreadActionType = .viewMoreReplies(count: extendedRepliesCount)
        } else {
            commentThreadActionType = .viewMoreRepliesRange(from: extendedRepliesCount, to: totalRepliesCount)
        }
        return commentThreadActionType
    }
}

extension OWCommentThreadActionsCellViewModel {
    static func stub() -> OWCommentThreadActionsCellViewModeling {
        return OWCommentThreadActionsCellViewModel()
    }
}
