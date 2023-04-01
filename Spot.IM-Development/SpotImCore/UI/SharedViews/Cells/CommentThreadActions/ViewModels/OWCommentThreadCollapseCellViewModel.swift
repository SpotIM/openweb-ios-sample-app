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

    init(data: OWCommentPresentationData) {
        self.commentPresentationData = data
    }

    init() {
        // TODO - make OWCommentPresentationData a class
        self.commentPresentationData = OWCommentPresentationData(id: "", shouldShowReplies: false, repliesIds: [], totalRepliesCount: 0, repliesOffset: 0, repliesPresentation: [])
    }
}

extension OWCommentThreadCollapseCellViewModel {
    static func stub() -> OWCommentThreadCollapseCellViewModeling {
        return OWCommentThreadCollapseCellViewModel()
    }
}
