//
//  OWConversationCellViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWConversationCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWConversationCellOption] {
        return [.comment(viewModel: OWCommentCellViewModel.stub()),
                .commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModel.stub()),
                .commentThreadActions(viewModel: OWCommentThreadActionsCellViewModel.stub()),
                .ad(viewModel: OWAdCellViewModel.stub()),
                .spacer(viewModel: OWSpacerCellViewModel.stub()),
                .communityQuestion(viewModel: OWCommunityQuestionCellViewModel.stub()),
                .communityGuidelines(viewModel: OWCommunityGuidelinesCellViewModel.stub()),
                .conversationEmptyState(viewModel: OWConversationEmptyStateCellViewModel.stub()),
                .conversationErrorState(viewModel: OWErrorStateCellViewModel.stub()),
                .loading(viewModel: OWLoadingCellViewModel.stub())]
    }

    case comment(viewModel: OWCommentCellViewModeling)
    case commentSkeletonShimmering(viewModel: OWCommentSkeletonShimmeringCellViewModeling)
    case commentThreadActions(viewModel: OWCommentThreadActionsCellViewModeling)
    case ad(viewModel: OWAdCellViewModeling)
    case spacer(viewModel: OWSpacerCellViewModeling)
    case communityQuestion(viewModel: OWCommunityQuestionCellViewModeling)
    case communityGuidelines(viewModel: OWCommunityGuidelinesCellViewModeling)
    case conversationEmptyState(viewModel: OWConversationEmptyStateCellViewModeling)
    case conversationErrorState(viewModel: OWErrorStateCellViewModeling)
    case loading(viewModel: OWLoadingCellViewModeling)
}

extension OWConversationCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .comment(let viewModel):
            return viewModel
        case .commentSkeletonShimmering(let viewModel):
            return viewModel
        case .commentThreadActions(let viewModel):
            return viewModel
        case .ad(let viewModel):
            return viewModel
        case .spacer(let viewModel):
            return viewModel
        case .communityQuestion(let viewModel):
            return viewModel
        case .communityGuidelines(let viewModel):
            return viewModel
        case .conversationEmptyState(viewModel: let viewModel):
            return viewModel
        case .conversationErrorState(viewModel: let viewModel):
            return viewModel
        case .loading(viewModel: let viewModel):
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
        case .ad:
            return UITableViewCell.self
        case .spacer:
            return OWSpacerCell.self
        case .communityQuestion:
            return OWCommunityQuestionCell.self
        case .communityGuidelines:
            return OWCommunityGuidelinesCell.self
        case .conversationEmptyState:
            return OWConversationEmptyStateCell.self
        case .conversationErrorState:
            return OWErrorStateCell.self
        case .loading:
            return OWLoadingCell.self
        }
    }
}

extension OWConversationCellOption: Equatable {
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
        case .ad:
            return ""
//            return viewModel.outputs.id
        case .spacer(let viewModel):
            return viewModel.outputs.id
        case .communityQuestion(let viewModel):
            return viewModel.outputs.id
        case .communityGuidelines(let viewModel):
            return viewModel.outputs.id
        case .conversationEmptyState(viewModel: let viewModel):
            return viewModel.outputs.id
        case .conversationErrorState(viewModel: let viewModel):
            return viewModel.outputs.id
        case .loading(viewModel: let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWConversationCellOption, rhs: OWConversationCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.comment(_), .comment(_)):
            return lhs.identifier == rhs.identifier
        case (.commentSkeletonShimmering(_), .commentSkeletonShimmering(_)):
            return lhs.identifier == rhs.identifier
        case (.commentThreadActions(_), .commentThreadActions(_)):
            return lhs.identifier == rhs.identifier
        case (.ad(_), .ad(_)):
            return lhs.identifier == rhs.identifier
        case (.spacer(_), .spacer(_)):
            return lhs.identifier == rhs.identifier
        default:
            return false
        }
    }
}

extension OWConversationCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}

