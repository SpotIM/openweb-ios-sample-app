//
//  OWFilterTabsCellOption.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 17/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWFilterTabsCellOption: CaseIterable, OWUpdaterProtocol {
    static var allCases: [OWFilterTabsCellOption] {
        return [.filterTab(viewModel: OWFilterTabsCollectionCellViewModel.stub()),
                .filterTabSkeleton(viewModel: OWFilterTabsSkeletonCollectionCellVM.stub())]
    }

    case filterTab(viewModel: OWFilterTabsCollectionCellViewModeling)
    case filterTabSkeleton(viewModel: OWFilterTabsSkeletonCollectionCellViewModeling)
}

extension OWFilterTabsCellOption {
    var viewModel: OWCellViewModel {
        switch self {
        case .filterTab(let viewModel):
            return viewModel
        case .filterTabSkeleton(let viewModel):
            return viewModel
        }
    }

    var cellClass: UICollectionViewCell.Type {
        switch self {
        case .filterTab:
            return OWFilterTabsCollectionCell.self
        case .filterTabSkeleton:
            return OWFilterTabsSkeletonCollectionCell.self
        }
    }
}

extension OWFilterTabsCellOption: Equatable {
    var identifier: String {
        switch self {
        case .filterTab(let viewModel):
            return viewModel.outputs.tabId
        case .filterTabSkeleton(let viewModel):
            return viewModel.outputs.id
        }
    }

    static func == (lhs: OWFilterTabsCellOption, rhs: OWFilterTabsCellOption) -> Bool {
        switch (lhs, rhs) {
        case (.filterTab(_), .filterTab(_)):
            return lhs.identifier == rhs.identifier
        case (.filterTabSkeleton(_), .filterTabSkeleton(_)):
            return lhs.identifier == rhs.identifier
        default:
            return false
        }
    }
}

extension OWFilterTabsCellOption: OWIdentifiableType {
    var identity: String {
        return self.identifier
    }
}
