//
//  OWConversationCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

enum OWConversationCellOption: CaseIterable {
    static var allCases: [OWConversationCellOption] {
        return [.comment(viewModel: OWCommentViewModel.stub()),
                .reply(viewModel: OWReplyViewModel.stub()),
                .ad(viewModel: OWAdViewModel.stub()),
                .spacer(viewModel: OWSpacerViewModel.stub())]
    }
    
    case comment(viewModel: OWCommentViewModeling)
    case reply(viewModel: OWReplyViewModeling)
    case ad(viewModel: OWAdViewModeling)
    case spacer(viewModel: OWSpacerViewModeling)
}

extension OWConversationCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .comment(let viewModel):
            return viewModel
        case .reply(let viewModel):
            return viewModel
        case .ad(let viewModel):
            return viewModel
        case .spacer(let viewModel):
            return viewModel
        }
    }
    
    var cellClass: UITableViewCell.Type {
        // TODO: Return the actual cell type once developed
        switch self {
        case .comment:
            return UITableViewCell.self
        case .reply:
            return UITableViewCell.self
        case .ad:
            return UITableViewCell.self
        case .spacer:
            return UITableViewCell.self
        }
    }
}

extension OWConversationCellOption: Equatable  {
    var identifier: String {
        return ""
        // TODO: Once developed, return id of the comment/reply/ad for each.
        // Spacer will also have a specific id which will be generated with "UUID" as the VM created.
        // This is necessary so we won't have UI animations/flickering when loading the same data.
//        switch self {
//        case .comment(let viewModel):
//            return viewModel.outputs.id
//        case .reply(let viewModel):
//            return viewModel.outputs.id
//        case .ad(let viewModel):
//            return viewModel.outputs.id
//        case .spacer(let viewModel):
//            return viewModel.outputs.id
//        }
    }
   
    static func == (lhs: OWConversationCellOption, rhs: OWConversationCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.comment(_), .comment(_)):
            return lhs.identifier == rhs.identifier
        case (.reply(_), .reply(_)):
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

