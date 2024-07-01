//
//  OWFilterTabsSkeletonCollectionCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 17/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWFilterTabsSkeletonCollectionCellViewModelingInputs { }

protocol OWFilterTabsSkeletonCollectionCellViewModelingOutputs {
    var id: String { get }
}

protocol OWFilterTabsSkeletonCollectionCellViewModeling: OWCellViewModel {
    var inputs: OWFilterTabsSkeletonCollectionCellViewModelingInputs { get }
    var outputs: OWFilterTabsSkeletonCollectionCellViewModelingOutputs { get }
}

class OWFilterTabsSkeletonCollectionCellVM: OWFilterTabsSkeletonCollectionCellViewModeling,
                                           OWFilterTabsSkeletonCollectionCellViewModelingInputs,
                                           OWFilterTabsSkeletonCollectionCellViewModelingOutputs {
    var inputs: OWFilterTabsSkeletonCollectionCellViewModelingInputs { return self }
    var outputs: OWFilterTabsSkeletonCollectionCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWFilterTabsSkeletonCollectionCellVM {
    static func stub() -> OWFilterTabsSkeletonCollectionCellVM {
        return OWFilterTabsSkeletonCollectionCellVM()
    }
}
