//
//  CommentCreationToolbarViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol CommentCreationToolbarViewModelingInputs {}

protocol CommentCreationToolbarViewModelingOutputs {
    var toolbarCellsVM: Observable<[ToolbarCollectionCellViewModeling]> { get }
}

protocol CommentCreationToolbarViewModeling {
    var inputs: CommentCreationToolbarViewModelingInputs { get }
    var outputs: CommentCreationToolbarViewModelingOutputs { get }
}

class CommentCreationToolbarViewModel: CommentCreationToolbarViewModeling,
                                    CommentCreationToolbarViewModelingInputs,
                                   CommentCreationToolbarViewModelingOutputs {
    var inputs: CommentCreationToolbarViewModelingInputs { return self }
    var outputs: CommentCreationToolbarViewModelingOutputs { return self }

    var _toolbarCellsVM = BehaviorSubject<[ToolbarCollectionCellViewModeling]?>(value: nil)
    var toolbarCellsVM: Observable<[ToolbarCollectionCellViewModeling]> {
        return _toolbarCellsVM
            .unwrap()
    }
}
