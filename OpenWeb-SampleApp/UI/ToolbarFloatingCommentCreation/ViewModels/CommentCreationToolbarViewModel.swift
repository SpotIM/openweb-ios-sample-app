//
//  CommentCreationToolbarViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine
import OpenWebSDK

protocol CommentCreationToolbarViewModelingInputs {
    var modelSelected: PassthroughSubject<ToolbarCollectionCellViewModeling, Never> { get }
    func setCommentCreationSettings(_ settings: OWCommentCreationSettingsProtocol)
}

protocol CommentCreationToolbarViewModelingOutputs {
    var toolbarCellsVM: CurrentValueSubject<[ToolbarCollectionCellViewModel]?, Never> { get }
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

    private var cancellables = Set<AnyCancellable>()

    var toolbarCellsVM = CurrentValueSubject<[ToolbarCollectionCellViewModel]?, Never>(value: nil)

    init(toolbarElments: [ToolbarElementModel]) {
        let cellsVms = toolbarElments.map { ToolbarCollectionCellViewModel(model: $0) }
        self.toolbarCellsVM.send(cellsVms)
        setupObservers()
    }

    var modelSelected = PassthroughSubject<ToolbarCollectionCellViewModeling, Never>()

    private var commentCreationSettings: OWCommentCreationSettingsProtocol?
    func setCommentCreationSettings(_ settings: OWCommentCreationSettingsProtocol) {
        commentCreationSettings = settings
    }
}

private extension CommentCreationToolbarViewModel {
    func setupObservers() {
        modelSelected
            .sink(receiveValue: { [weak self] cellViewModel in
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
            .store(in: &cancellables)
    }
}
