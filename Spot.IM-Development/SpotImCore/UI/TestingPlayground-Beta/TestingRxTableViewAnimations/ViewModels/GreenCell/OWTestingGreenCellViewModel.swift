//
//  OWTestingGreenCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingGreenCellViewModelingInputs { }

protocol OWTestingGreenCellViewModelingOutputs {
    var id: String { get }
}

protocol OWTestingGreenCellViewModeling: OWCellViewModel {
    var inputs: OWTestingGreenCellViewModelingInputs { get }
    var outputs: OWTestingGreenCellViewModelingOutputs { get }
}

class OWTestingGreenCellViewModel: OWTestingGreenCellViewModeling,
                                OWTestingGreenCellViewModelingInputs,
                                OWTestingGreenCellViewModelingOutputs {
    var inputs: OWTestingGreenCellViewModelingInputs { return self }
    var outputs: OWTestingGreenCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

#endif
