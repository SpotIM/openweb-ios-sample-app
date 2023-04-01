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

    init(data: OWCommentPresentationData) {
        self.commentPresentationData = data
    }

    init() {
        // TODO - make OWCommentPresentationData a class
        self.commentPresentationData = OWCommentPresentationData(id: "", shouldShowReplies: false, repliesIds: [], totalRepliesCount: 0, repliesOffset: 0, repliesPresentation: [])
    }
}

extension OWCommentThreadExpandCellViewModel {
    static func stub() -> OWCommentThreadExpandCellViewModeling {
        return OWCommentThreadExpandCellViewModel()
    }
}
