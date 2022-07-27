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
