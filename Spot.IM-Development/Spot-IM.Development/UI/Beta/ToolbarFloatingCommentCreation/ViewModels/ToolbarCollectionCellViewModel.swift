//
//  ToolbarCollectionCellViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol ToolbarCollectionCellViewModelingInputs {}

protocol ToolbarCollectionCellViewModelingOutputs {
    var emoji: Observable<String> { get }
    var action: ToolbarElementAction { get }
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

    fileprivate let model: ToolbarElementModel

    fileprivate let _emoji = BehaviorSubject<String?>(value: nil)
    var emoji: Observable<String> {
        return _emoji
            .unwrap()
    }

    var action: ToolbarElementAction {
        return model.action
    }

    init(model: ToolbarElementModel) {
        self.model = model

        _emoji.onNext(model.emoji)
    }
}
