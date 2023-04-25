//
//  OWTestingRxTableViewAnimationsViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRxTableViewAnimationsViewViewModelingInputs { }

protocol OWTestingRxTableViewAnimationsViewViewModelingOutputs { }

protocol OWTestingRxTableViewAnimationsViewViewModeling {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { get }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { get }
}

class OWTestingRxTableViewAnimationsViewViewModel: OWTestingRxTableViewAnimationsViewViewModeling,
                                OWTestingRxTableViewAnimationsViewViewModelingInputs,
                                OWTestingRxTableViewAnimationsViewViewModelingOutputs {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { return self }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { return self }

}

#endif
