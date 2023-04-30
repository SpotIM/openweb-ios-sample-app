//
//  OWTestingRedSecondLevelViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRedSecondLevelViewModelingInputs { }

protocol OWTestingRedSecondLevelViewModelingOutputs {
    var id: String { get } // Used for presentation inside the label
}

protocol OWTestingRedSecondLevelViewModeling {
    var inputs: OWTestingRedSecondLevelViewModelingInputs { get }
    var outputs: OWTestingRedSecondLevelViewModelingOutputs { get }
}

class OWTestingRedSecondLevelViewModel: OWTestingRedSecondLevelViewModeling,
                                OWTestingRedSecondLevelViewModelingInputs,
                                OWTestingRedSecondLevelViewModelingOutputs {
    var inputs: OWTestingRedSecondLevelViewModelingInputs { return self }
    var outputs: OWTestingRedSecondLevelViewModelingOutputs { return self }

    let id: String

    init(id: String) {
        self.id = id
    }
}

#endif
