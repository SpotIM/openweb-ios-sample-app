//
//  OWTestingRxTableViewCellOption.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit

enum OWTestingRxTableViewCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWTestingRxTableViewCellOption] {
        return [.red(viewModel: OWTestingRedCellViewModel()),
                .blue(viewModel: OWTestingBlueCellViewModel()),
                .green(viewModel: OWTestingGreenCellViewModel())]
    }

    case red(viewModel: OWTestingRedCellViewModeling)
    case blue(viewModel: OWTestingBlueCellViewModeling)
    case green(viewModel: OWTestingGreenCellViewModeling)
}

extension OWTestingRxTableViewCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .red(let viewModel):
            return viewModel
        case .blue(let viewModel):
            return viewModel
        case .green(let viewModel):
            return viewModel
        }
    }

    var cellClass: UITableViewCell.Type {
        switch self {
        case .red:
            return OWTestingRedCell.self
        case .blue:
            return OWTestingBlueCell.self
        case .green:
            return OWTestingGreenCell.self
        }
    }
}

extension OWTestingRxTableViewCellOption: Equatable {
    var identifier: String {
        switch self {
        case .red(let viewModel):
            return viewModel.outputs.id
        case .blue(let viewModel):
            return viewModel.outputs.id
        case .green(let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWTestingRxTableViewCellOption, rhs: OWTestingRxTableViewCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.red(_), .red(_)):
            return lhs.identifier == rhs.identifier && lhs.viewModel === rhs.viewModel
        case (.blue(_), .blue(_)):
            return lhs.identifier == rhs.identifier && lhs.viewModel === rhs.viewModel
        case (.green(_), .green(_)):
            return lhs.identifier == rhs.identifier && lhs.viewModel === rhs.viewModel
        default:
            return false
        }
    }
}

extension OWTestingRxTableViewCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}

#endif
