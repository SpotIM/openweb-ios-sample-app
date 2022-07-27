//
//  OWAdViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAdViewModelingInputs {
    
}

protocol OWAdViewModelingOutputs {
    
}

protocol OWAdViewModeling: OWCellViewModel {
    var inputs: OWAdViewModelingInputs { get }
    var outputs: OWAdViewModelingOutputs { get }
}

class OWAdViewModel: OWAdViewModeling, OWAdViewModelingInputs, OWAdViewModelingOutputs {
    var inputs: OWAdViewModelingInputs { return self }
    var outputs: OWAdViewModelingOutputs { return self }
}

extension OWAdViewModel {
    static func stub() -> OWAdViewModeling {
        return OWAdViewModel()
    }
}
