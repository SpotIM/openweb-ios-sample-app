//
//  OWUserMentionsCellOption.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 01/05/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWUserMentionsCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWUserMentionsCellOption] {
        return [.mention(viewModel: OWUserMentionCellViewModel.stub()),
                .searching(viewModel: OWUserMentionSearchingCellViewModel.stub())]
    }

    case mention(viewModel: OWUserMentionCellViewModeling)
    case searching(viewModel: OWUserMentionSearchingCellViewModeling)
}

extension OWUserMentionsCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .mention(let viewModel):
            return viewModel
        case .searching(let viewModel):
            return viewModel
        }
    }

    var cellClass: UITableViewCell.Type {
        switch self {
        case .mention:
            return OWUserMentionCell.self
        case .searching:
            return OWUserMentionSearchingCell.self
        }
    }
}

extension OWUserMentionsCellOption: Equatable {
    var identifier: String {
        switch self {
        case .mention(let viewModel):
            return viewModel.outputs.id
        case .searching(let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWUserMentionsCellOption, rhs: OWUserMentionsCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.mention(_), .mention(_)):
            return lhs.identifier == rhs.identifier
        case (.searching(_), .searching(_)):
            return lhs.identifier == rhs.identifier
        default:
            return false
        }
    }
}

extension OWUserMentionsCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}
