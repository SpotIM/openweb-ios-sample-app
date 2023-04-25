//
//  OWTestingRedFirstLevelViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRedFirstLevelViewModelingInputs { }

protocol OWTestingRedFirstLevelViewModelingOutputs {
    var secondLevelVM: OWTestingRedSecondLevelViewModeling { get }
}

protocol OWTestingRedFirstLevelViewModeling {
    var inputs: OWTestingRedFirstLevelViewModelingInputs { get }
    var outputs: OWTestingRedFirstLevelViewModelingOutputs { get }
}

class OWTestingRedFirstLevelViewModel: OWTestingRedFirstLevelViewModeling,
                                OWTestingRedFirstLevelViewModelingInputs,
                                OWTestingRedFirstLevelViewModelingOutputs {
    var inputs: OWTestingRedFirstLevelViewModelingInputs { return self }
    var outputs: OWTestingRedFirstLevelViewModelingOutputs { return self }

    lazy var secondLevelVM: OWTestingRedSecondLevelViewModeling = {
        return OWTestingRedSecondLevelViewModel()
    }()
}

#endif
