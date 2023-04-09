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
}

protocol OWCommentThreadExpandCellViewModeling: OWCellViewModel {
    var inputs: OWCommentThreadExpandCellViewModelingInputs { get }
    var outputs: OWCommentThreadExpandCellViewModelingOutputs { get }
}

class OWCommentThreadExpandCellViewModel: OWCommentThreadExpandCellViewModeling, OWCommentThreadExpandCellViewModelingInputs, OWCommentThreadExpandCellViewModelingOutputs {
    var inputs: OWCommentThreadExpandCellViewModelingInputs { return self }
    var outputs: OWCommentThreadExpandCellViewModelingOutputs { return self }

    var id: String = UUID().uuidString

    let commentPresentationData: OWCommentPresentationData

    let commentActionsVM: OWCommentThreadActionsViewModel

    init(data: OWCommentPresentationData) {
        self.commentPresentationData = data

        // TODO - Add data
        commentActionsVM = OWCommentThreadActionsViewModel()
    }

    init() {
        // TODO - make OWCommentPresentationData a class
        self.commentPresentationData = OWCommentPresentationData(id: "", totalRepliesCount: 0, repliesOffset: 0)

        commentActionsVM = OWCommentThreadActionsViewModel()
    }
}

extension OWCommentThreadExpandCellViewModel {
    static func stub() -> OWCommentThreadExpandCellViewModeling {
        return OWCommentThreadExpandCellViewModel()
    }
}
