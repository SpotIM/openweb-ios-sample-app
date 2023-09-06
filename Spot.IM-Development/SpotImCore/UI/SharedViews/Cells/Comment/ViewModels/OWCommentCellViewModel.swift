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
    var spacingBetweenComments: CGFloat { get }
    var id: String { get }
    var viewAccessibilityIdentifier: String { get }
}

protocol OWCommentCellViewModeling: OWCellViewModel {
    var inputs: OWCommentCellViewModelingInputs { get }
    var outputs: OWCommentCellViewModelingOutputs { get }
}

class OWCommentCellViewModel: OWCommentCellViewModeling, OWCommentCellViewModelingInputs, OWCommentCellViewModelingOutputs {
    fileprivate struct Metrics {
        static let viewAccessibilityIdentifier = "comment_cell_id_"
    }

    var inputs: OWCommentCellViewModelingInputs { return self }
    var outputs: OWCommentCellViewModelingOutputs { return self }

    lazy var viewAccessibilityIdentifier: String = {
        return Metrics.viewAccessibilityIdentifier + id
    }()

    let spacingBetweenComments: CGFloat
    let commentVM: OWCommentViewModeling

    var id: String = ""

    init(data: OWCommentRequiredData,
         spacing: CGFloat = OWConversationSpacing.regular.betweenComments / 2) {
        self.id = data.comment.id ?? ""

        self.commentVM = OWCommentViewModel(data: data)
        self.spacingBetweenComments = spacing
    }

    init() {
        self.commentVM = OWCommentViewModel()
        self.spacingBetweenComments = OWConversationSpacing.regular.betweenComments / 2
    }
}

extension OWCommentCellViewModel {
    static func stub() -> OWCommentCellViewModeling {
        return OWCommentCellViewModel()
    }
}
