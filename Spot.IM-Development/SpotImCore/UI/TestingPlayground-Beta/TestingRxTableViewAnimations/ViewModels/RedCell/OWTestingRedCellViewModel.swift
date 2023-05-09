//
//  OWTestingRedCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRedCellViewModelingInputs { }

protocol OWTestingRedCellViewModelingOutputs {
    var id: String { get }
    var firstLevelVM: OWTestingRedFirstLevelViewModeling { get }
    func copy() -> OWTestingRedCellViewModeling
}

protocol OWTestingRedCellViewModeling: OWCellViewModel {
    var inputs: OWTestingRedCellViewModelingInputs { get }
    var outputs: OWTestingRedCellViewModelingOutputs { get }
}

class OWTestingRedCellViewModel: OWTestingRedCellViewModeling,
                                OWTestingRedCellViewModelingInputs,
                                OWTestingRedCellViewModelingOutputs {
    var inputs: OWTestingRedCellViewModelingInputs { return self }
    var outputs: OWTestingRedCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String

    lazy var firstLevelVM: OWTestingRedFirstLevelViewModeling = {
        return OWTestingRedFirstLevelViewModel(id: id)
    }()

    init(id: String = UUID().uuidString) {
        self.id = id
    }

    func copy() -> OWTestingRedCellViewModeling {
        let newVM = OWTestingRedCellViewModel(id: self.id)
        _ = self.firstLevelVM.outputs.secondLevelVM
            .outputs.changedCellState
            .take(1)
            .subscribe(onNext: { state in
                newVM.firstLevelVM.outputs.secondLevelVM
                    .inputs.changeCellStateTo.onNext(state)
            })
        return newVM
    }
}

#endif
