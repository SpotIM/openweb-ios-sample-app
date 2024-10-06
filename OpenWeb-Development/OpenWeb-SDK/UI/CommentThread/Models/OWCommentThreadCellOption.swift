//
//  OWCommentThreadCellOption.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 08/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWCommentThreadCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWCommentThreadCellOption] {
        return [
            .comment(viewModel: OWCommentCellViewModel.stub()),
            .commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModel.stub()),
            .spacer(viewModel: OWSpacerCellViewModel.stub()),
            .commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel.stub()),
            .conversationErrorState(viewModel: OWErrorStateCellViewModel.stub())
        ]
    }

    case comment(viewModel: OWCommentCellViewModeling)
    case commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModeling)
    case spacer(viewModel: OWSpacerCellViewModeling)
    case commentThreadActions(viewModel: OWCommentThreadActionsCellViewModeling)
    case conversationErrorState(viewModel: OWErrorStateCellViewModeling)
    case loading(viewModel: OWLoadingCellViewModeling)
}

extension OWCommentThreadCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .comment(let viewModel):
            return viewModel
        case .commentSkeletonShimmering(let viewModel):
            return viewModel
        case .spacer(let viewModel):
            return viewModel
        case .commentThreadActions(let viewModel):
            return viewModel
        case .conversationErrorState(viewModel: let viewModel):
            return viewModel
        case .loading(viewModel: let viewModel):
            return viewModel
        }
    }

    var cellClass: UITableViewCell.Type {
        switch self {
        case .comment:
            return OWCommentCell.self
        case .commentSkeletonShimmering:
            return OWCommentSkeletonShimmeringCell.self
        case .spacer:
            return OWSpacerCell.self
        case .commentThreadActions:
            return OWCommentThreadActionCell.self
        case .conversationErrorState:
            return OWErrorStateCell.self
        case .loading:
            return OWLoadingCell.self
        }
    }
}

extension OWCommentThreadCellOption: Equatable {
    var identifier: String {
        switch self {
        case .comment(let viewModel):
            return viewModel.outputs.id
        case .commentSkeletonShimmering(let viewModel):
            return viewModel.outputs.id
        case .spacer(let viewModel):
            return viewModel.outputs.id
        case .commentThreadActions(let viewModel):
            return viewModel.outputs.id
        case .conversationErrorState(viewModel: let viewModel):
            return viewModel.outputs.id
        case .loading(viewModel: let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWCommentThreadCellOption, rhs: OWCommentThreadCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.comment(_), .comment(_)):
            return lhs.identifier == rhs.identifier
        case (.commentSkeletonShimmering(_), .commentSkeletonShimmering(_)):
            return lhs.identifier == rhs.identifier
        case (.spacer(_), .spacer(_)):
            return lhs.identifier == rhs.identifier
        case (.commentThreadActions(_), .commentThreadActions(_)):
            return lhs.identifier == rhs.identifier
        default:
            return false
        }
    }
}

extension OWCommentThreadCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}
