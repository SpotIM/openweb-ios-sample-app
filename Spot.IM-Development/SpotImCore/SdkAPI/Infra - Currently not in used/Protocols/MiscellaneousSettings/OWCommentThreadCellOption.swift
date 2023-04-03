//
//  OWCommentThreadCellOption.swift
//  SpotImCore
//
//  Created by Alon Shprung on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

enum OWCommentThreadCellOption: CaseIterable {
    static var allCases: [OWCommentThreadCellOption] {
        return [
            .comment(viewModel: OWCommentCellViewModel.stub()),
            .commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModel.stub()),
            .spacer(viewModel: OWSpacerCellViewModel.stub()),
            .commentThreadCollapse(viewModel: OWCommentThreadCollapseCellViewModel.stub()),
            .commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModel.stub())
        ]
    }

    case comment(viewModel: OWCommentCellViewModeling)
    case commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModeling)
    case spacer(viewModel: OWSpacerCellViewModeling)
    case commentThreadCollapse(viewModel: OWCommentThreadCollapseCellViewModeling)
    case commentThreadExpand(viewModel: OWCommentThreadExpandCellViewModeling)
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
        case .commentThreadCollapse(let viewModel):
            return viewModel
        case .commentThreadExpand(let viewModel):
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
        case .commentThreadCollapse:
            return OWCommentThreadCollapseCell.self
        case .commentThreadExpand:
            return OWCommentThreadExpandCell.self
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
        case .commentThreadCollapse(let viewModel):
            return viewModel.outputs.id
        case .commentThreadExpand(let viewModel):
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
        case (.commentThreadCollapse(_), .commentThreadCollapse(_)):
            return lhs.identifier == rhs.identifier
        case (.commentThreadExpand(_), .commentThreadExpand(_)):
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

