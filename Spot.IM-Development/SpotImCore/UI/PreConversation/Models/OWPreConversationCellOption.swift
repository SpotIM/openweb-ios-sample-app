//
//  OWPreConversationCellOption.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

enum OWPreConversationCellOption: CaseIterable {
    static var allCases: [OWPreConversationCellOption] {
        return [.comment(viewModel: OWCommentCellViewModel.stub()),
                .commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModel.stub()),
                .spacer(viewModel: OWSpacerCellViewModel.stub())]
    }
    
    case comment(viewModel: OWCommentCellViewModeling)
    case commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModeling)
    case spacer(viewModel: OWSpacerCellViewModeling)
}

extension OWPreConversationCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .comment(let viewModel):
            return viewModel
        case .commentSkeletonShimmering(let viewModel):
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
        case .spacer:
            return UITableViewCell.self
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
            return ""
        case .commentSkeletonShimmering(let viewModel):
            return viewModel.outputs.id
        case .spacer(let viewModel):
            return ""
        }
    }
   
    static func == (lhs: OWPreConversationCellOption, rhs: OWPreConversationCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.comment(_), .comment(_)):
            return lhs.identifier == rhs.identifier
        case (.commentSkeletonShimmering(_), .commentSkeletonShimmering(_)):
            return lhs.identifier == rhs.identifier
        case (.spacer(_), .spacer(_)):
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

