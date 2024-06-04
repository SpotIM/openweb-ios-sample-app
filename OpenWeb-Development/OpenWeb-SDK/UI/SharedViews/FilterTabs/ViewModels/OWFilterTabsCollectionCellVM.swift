//
//  OWFilterTabsCollectionCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWFilterTabsCollectionCellViewModelingInputs {}

protocol OWFilterTabsCollectionCellViewModelingOutputs {
    var accessibilityPrefix: String { get }
    var isSelected: Observable<Bool> { get }
    var text: String { get }
}

protocol OWFilterTabsCollectionCellViewModeling {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { get }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { get }
}

class OWFilterTabsCollectionCellViewModel: OWFilterTabsCollectionCellViewModeling,
                                           OWFilterTabsCollectionCellViewModelingInputs,
                                           OWFilterTabsCollectionCellViewModelingOutputs {
    var inputs: OWFilterTabsCollectionCellViewModelingInputs { return self }
    var outputs: OWFilterTabsCollectionCellViewModelingOutputs { return self }

    fileprivate let model: OWFilterTabObject

    var accessibilityPrefix: String {
        model.name
    }

    lazy var text: String = {
        return model.name + (model.id == "all" ? "" : " (\(model.count))")
    }()

    var _isSelected = BehaviorSubject<Bool>(value: false)
    var isSelected: Observable<Bool> {
        return _isSelected
            .asObservable()
    }

    init(model: OWFilterTabObject) {
        self.model = model
    }
}
