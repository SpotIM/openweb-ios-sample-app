//
//  CommentCreationToolbarViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol CommentCreationToolbarViewModelingInputs {
    var modelSelected: PublishSubject<ToolbarCollectionCellViewModeling> { get }
    func setCommentCreationSettings(_ settings: OWCommentCreationSettingsProtocol)
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

    fileprivate var commentCreationSettings: OWCommentCreationSettingsProtocol?
    func setCommentCreationSettings(_ settings: OWCommentCreationSettingsProtocol) {
        commentCreationSettings = settings
    }
}

fileprivate extension CommentCreationToolbarViewModel {
    func setupObservers() {
        modelSelected
            .subscribe(onNext: { [weak self] cellViewModel in
                guard let self = self,
                        let settings = self.commentCreationSettings else { return }
                settings.request(.manipulateUserInputText(completion: { result in
                    let action = cellViewModel.outputs.action
                    switch (result, action) {
                    case (.success(let manipulateTextModel), .append(let textToAppend)):
                        let userTextInput = manipulateTextModel.text
                        let range = manipulateTextModel.cursorRange
                        let newText = userTextInput.replacingCharacters(in: range, with: " \(textToAppend)")
                        return newText
                    case (.success(_), .removeAll):
                        return ""
                    default:
                        let textToLog = "Received an error when tried to request `manipulateUserInputText` request option"
                        DLog(textToLog)
                        return ""
                    }
                }))
            })
            .disposed(by: disposeBag)
    }
}

#endif
