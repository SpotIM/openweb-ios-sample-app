//
//  OWPreConversationCellOption.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWPreConversationCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWPreConversationCellOption] {
        return [.comment(viewModel: OWCommentCellViewModel.stub()),
                .commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModel.stub()),
                .commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel.stub()),
                .spacer(viewModel: OWSpacerCellViewModel.stub())]
    }

    case comment(viewModel: OWCommentCellViewModeling)
    case commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModeling)
    case commentThreadActions(viewModel: OWCommentThreadActionsCellViewModeling)
    case spacer(viewModel: OWSpacerCellViewModeling)
}

extension OWPreConversationCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .comment(let viewModel):
            return viewModel
        case .commentSkeletonShimmering(let viewModel):
            return viewModel
        case .commentThreadActions(let viewModel):
            return viewModel
        case .spacer(let viewModel):
            return viewModel
        }
    }

    var cellClass: UITableViewCell.Type {
        // TODO: Return the actual cell type once developed
        switch self {
        case .comment:
            return OWCommentCell.self
        case .commentSkeletonShimmering:
            return OWCommentSkeletonShimmeringCell.self
        case .commentThreadActions:
            return OWCommentThreadActionCell.self
        case .spacer:
            return OWSpacerCell.self
        }
    }
}

extension OWPreConversationCellOption: Equatable {
    var identifier: String {
        // TODO: Once developed, return id of the comment/reply/ad for each.
        // Spacer will also have a specific id which will be generated with "UUID" as the VM created.
        // This is necessary so we won't have UI animations/flickering when loading the same data.
        switch self {
        case .comment(let viewModel):
            return viewModel.outputs.id
        case .commentSkeletonShimmering(let viewModel):
            return viewModel.outputs.id
        case .commentThreadActions(let viewModel):
            return viewModel.outputs.id
        case .spacer(let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWPreConversationCellOption, rhs: OWPreConversationCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.comment, .comment):
            return lhs.identifier == rhs.identifier
        case (.commentSkeletonShimmering, .commentSkeletonShimmering):
            return lhs.identifier == rhs.identifier
        case (.commentThreadActions, .commentThreadActions):
            return lhs.identifier == rhs.identifier
        case (.spacer, .spacer):
            return lhs.identifier == rhs.identifier
        default:
            return false
        }
    }
}

extension OWPreConversationCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}
