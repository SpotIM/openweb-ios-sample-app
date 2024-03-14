//
//  OWCancelVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCancelViewModelingInputs { }
protocol OWCancelViewModelingOutputs {
    var cancelViewViewModel: OWCancelViewViewModeling { get }
}

protocol OWCancelViewModeling {
    var inputs: OWCancelViewModelingInputs { get }
    var outputs: OWCancelViewModelingOutputs { get }
}

class OWCancelViewModel: OWCancelViewModeling, OWCancelViewModelingOutputs, OWCancelViewModelingInputs {
    var inputs: OWCancelViewModelingInputs { return self }
    var outputs: OWCancelViewModelingOutputs { return self }

    let cancelViewViewModel: OWCancelViewViewModeling

    init(cancelViewViewModel: OWCancelViewViewModeling) {
        self.cancelViewViewModel = cancelViewViewModel
    }
}
