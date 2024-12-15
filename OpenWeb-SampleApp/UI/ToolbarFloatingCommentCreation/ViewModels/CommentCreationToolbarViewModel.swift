//
//  CommentCreationToolbarViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import OpenWebSDK

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

    private let disposeBag = DisposeBag()

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

    private var commentCreationSettings: OWCommentCreationSettingsProtocol?
    func setCommentCreationSettings(_ settings: OWCommentCreationSettingsProtocol) {
        commentCreationSettings = settings
    }
}

private extension CommentCreationToolbarViewModel {
    func setupObservers() {
        modelSelected
            .subscribe(onNext: { [weak self] cellViewModel in
                guard let self,
                      let settings = self.commentCreationSettings else { return }
                settings.request(.manipulateUserInputText(completion: { result in
                    let action = cellViewModel.outputs.action
                    switch (result, action) {
                    case (.success, .append(let textToAppend)):
                        return textToAppend
                    case (.success, .removeAll):
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
