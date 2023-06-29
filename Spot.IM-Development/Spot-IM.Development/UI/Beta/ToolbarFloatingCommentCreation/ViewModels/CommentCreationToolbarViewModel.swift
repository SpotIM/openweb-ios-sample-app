//
//  CommentCreationToolbarViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol CommentCreationToolbarViewModelingInputs {
    var modelSelected: PublishSubject<ToolbarCollectionCellViewModeling> { get }
}

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

    fileprivate let disposeBag = DisposeBag()

    var _toolbarCellsVM = BehaviorSubject<[ToolbarCollectionCellViewModeling]?>(value: nil)
    var toolbarCellsVM: Observable<[ToolbarCollectionCellViewModeling]> {
        return _toolbarCellsVM
            .unwrap()
    }

    init(toolbarElments: [ToolbarElementModel]) {
        let cellsVms = toolbarElments.map { ToolbarCollectionCellViewModel(model: $0) }
        self._toolbarCellsVM.onNext(cellsVms)
        setupObservers()
    }

    var modelSelected = PublishSubject<ToolbarCollectionCellViewModeling>()
}

fileprivate extension CommentCreationToolbarViewModel {
    func setupObservers() {
        modelSelected
            .subscribe(onNext: { _ in
                // TODO continue to activate "comment creation text manipulation"
            })
            .disposed(by: disposeBag)
    }
}
