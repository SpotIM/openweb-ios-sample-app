//
//  OWTestingBlueCellViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingBlueCellViewModelingInputs { }

protocol OWTestingBlueCellViewModelingOutputs {
    var id: String { get }
    var firstLevelVM: OWTestingBlueFirstLevelViewModeling { get }
    func copy() -> OWTestingBlueCellViewModeling
}

protocol OWTestingBlueCellViewModeling: OWCellViewModel {
    var inputs: OWTestingBlueCellViewModelingInputs { get }
    var outputs: OWTestingBlueCellViewModelingOutputs { get }
}

class OWTestingBlueCellViewModel: OWTestingBlueCellViewModeling,
                                OWTestingBlueCellViewModelingInputs,
                                OWTestingBlueCellViewModelingOutputs {
    var inputs: OWTestingBlueCellViewModelingInputs { return self }
    var outputs: OWTestingBlueCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String

    lazy var firstLevelVM: OWTestingBlueFirstLevelViewModeling = {
        return OWTestingBlueFirstLevelViewModel(id: id)
    }()

    init(id: String = UUID().uuidString) {
        self.id = id
    }

    func copy() -> OWTestingBlueCellViewModeling {
        let newVM = OWTestingBlueCellViewModel(id: self.id)
        _ = self.firstLevelVM.outputs.changedCellState
            .take(1)
            .subscribe(onNext: { state in
                newVM.firstLevelVM.inputs.changeCellStateTo.onNext(state)
            })
        return newVM
    }
}

#endif
