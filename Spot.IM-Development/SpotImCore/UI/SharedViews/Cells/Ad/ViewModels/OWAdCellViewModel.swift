//
//  OWAdCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAdCellViewModelingInputs {

}

protocol OWAdCellViewModelingOutputs {

}

protocol OWAdCellViewModeling: OWCellViewModel {
    var inputs: OWAdCellViewModelingInputs { get }
    var outputs: OWAdCellViewModelingOutputs { get }
}

class OWAdCellViewModel: OWAdCellViewModeling, OWAdCellViewModelingInputs, OWAdCellViewModelingOutputs {
    var inputs: OWAdCellViewModelingInputs { return self }
    var outputs: OWAdCellViewModelingOutputs { return self }
}

extension OWAdCellViewModel {
    static func stub() -> OWAdCellViewModeling {
        return OWAdCellViewModel()
    }
}
