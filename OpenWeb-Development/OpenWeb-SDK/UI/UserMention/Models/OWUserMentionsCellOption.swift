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
                .loading(viewModel: OWUserMentionLoadingCellViewModel.stub())]
    }

    case mention(viewModel: OWUserMentionCellViewModeling)
    case loading(viewModel: OWUserMentionLoadingCellViewModeling)
}

extension OWUserMentionsCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .mention(let viewModel):
            return viewModel
        case .loading(let viewModel):
            return viewModel
        }
    }

    var cellClass: UITableViewCell.Type {
        switch self {
        case .mention:
            return OWUserMentionCell.self
        case .loading:
            return OWUserMentionLoadingCell.self
        }
    }
}

extension OWUserMentionsCellOption: Equatable {
    var identifier: String {
        switch self {
        case .mention(let viewModel):
            return viewModel.outputs.id
        case .loading(let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWUserMentionsCellOption, rhs: OWUserMentionsCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.mention, .mention):
            return lhs.identifier == rhs.identifier
        case (.loading, .loading):
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
