//
//  ToolbarCollectionCellViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol ToolbarCollectionCellViewModelingInputs {}

protocol ToolbarCollectionCellViewModelingOutputs {
    var emoji: Observable<String> { get }
    var action: ToolbarElementAction { get }
    var accessibilityPrefix: String { get }
}

protocol ToolbarCollectionCellViewModeling {
    var inputs: ToolbarCollectionCellViewModelingInputs { get }
    var outputs: ToolbarCollectionCellViewModelingOutputs { get }
}

class ToolbarCollectionCellViewModel: ToolbarCollectionCellViewModeling,
                                    ToolbarCollectionCellViewModelingInputs,
                                   ToolbarCollectionCellViewModelingOutputs {
    var inputs: ToolbarCollectionCellViewModelingInputs { return self }
    var outputs: ToolbarCollectionCellViewModelingOutputs { return self }

    private let model: ToolbarElementModel

    private let _emoji = BehaviorSubject<String?>(value: nil)
    var emoji: Observable<String> {
        return _emoji
            .unwrap()
    }

    var action: ToolbarElementAction {
        return model.action
    }

    var accessibilityPrefix: String {
        model.accessibility
    }

    init(model: ToolbarElementModel) {
        self.model = model

        _emoji.onNext(model.emoji)
    }
}
