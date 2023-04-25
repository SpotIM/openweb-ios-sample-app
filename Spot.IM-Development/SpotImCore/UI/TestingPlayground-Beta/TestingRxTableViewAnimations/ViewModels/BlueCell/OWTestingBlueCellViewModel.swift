//
//  OWTestingBlueCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingBlueCellViewModelingInputs { }

protocol OWTestingBlueCellViewModelingOutputs {
    var id: String { get }
    var firstLevelVM: OWTestingBlueFirstLevelViewModeling { get }
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
    let id: String = UUID().uuidString

    lazy var firstLevelVM: OWTestingBlueFirstLevelViewModeling = {
        return OWTestingBlueFirstLevelViewModel()
    }()
}

#endif
