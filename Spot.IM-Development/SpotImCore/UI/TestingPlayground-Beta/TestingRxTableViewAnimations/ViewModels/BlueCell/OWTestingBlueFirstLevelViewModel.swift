//
//  OWTestingBlueFirstLevelViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingBlueFirstLevelViewModelingInputs { }

protocol OWTestingBlueFirstLevelViewModelingOutputs { }

protocol OWTestingBlueFirstLevelViewModeling {
    var inputs: OWTestingBlueFirstLevelViewModelingInputs { get }
    var outputs: OWTestingBlueFirstLevelViewModelingOutputs { get }
}

class OWTestingBlueFirstLevelViewModel: OWTestingBlueFirstLevelViewModeling,
                                OWTestingBlueFirstLevelViewModelingInputs,
                                OWTestingBlueFirstLevelViewModelingOutputs {
    var inputs: OWTestingBlueFirstLevelViewModelingInputs { return self }
    var outputs: OWTestingBlueFirstLevelViewModelingOutputs { return self }

}

#endif
