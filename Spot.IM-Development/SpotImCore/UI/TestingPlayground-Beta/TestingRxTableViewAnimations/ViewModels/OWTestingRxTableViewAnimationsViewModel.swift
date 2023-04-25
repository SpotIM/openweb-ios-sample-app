//
//  OWTestingRxTableViewAnimationsViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRxTableViewAnimationsViewModelingInputs { }

protocol OWTestingRxTableViewAnimationsViewModelingOutputs {
    var viewVM: OWTestingRxTableViewAnimationsViewViewModeling { get }
}

protocol OWTestingRxTableViewAnimationsViewModeling {
    var inputs: OWTestingRxTableViewAnimationsViewModelingInputs { get }
    var outputs: OWTestingRxTableViewAnimationsViewModelingOutputs { get }
}

class OWTestingRxTableViewAnimationsViewModel: OWTestingRxTableViewAnimationsViewModeling,
                                OWTestingRxTableViewAnimationsViewModelingInputs,
                                OWTestingRxTableViewAnimationsViewModelingOutputs {
    var inputs: OWTestingRxTableViewAnimationsViewModelingInputs { return self }
    var outputs: OWTestingRxTableViewAnimationsViewModelingOutputs { return self }

    lazy var viewVM: OWTestingRxTableViewAnimationsViewViewModeling = {
        return OWTestingRxTableViewAnimationsViewViewModel()
    }()
}

#endif
