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
    let id: String = UUID().uuidString

    lazy var firstLevelVM: OWTestingRedFirstLevelViewModeling = {
        return OWTestingRedFirstLevelViewModel()
    }()
}

#endif
