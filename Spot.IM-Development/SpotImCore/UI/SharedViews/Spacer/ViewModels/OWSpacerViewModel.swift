//
//  OWSpacerViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSpacerViewModelingInputs {
    
}

protocol OWSpacerViewModelingOutputs {
    
}

protocol OWSpacerViewModeling: OWCellViewModel {
    var inputs: OWSpacerViewModelingInputs { get }
    var outputs: OWSpacerViewModelingOutputs { get }
}

class OWSpacerViewModel: OWSpacerViewModeling, OWSpacerViewModelingInputs, OWSpacerViewModelingOutputs {
    var inputs: OWSpacerViewModelingInputs { return self }
    var outputs: OWSpacerViewModelingOutputs { return self }
}

extension OWSpacerViewModel {
    static func stub() -> OWSpacerViewModeling {
        return OWSpacerViewModel()
    }
}
