//
//  OWSpacerViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSpacerCellViewModelingInputs {

}

protocol OWSpacerCellViewModelingOutputs {
    var id: String { get }
}

protocol OWSpacerCellViewModeling: OWCellViewModel {
    var inputs: OWSpacerCellViewModelingInputs { get }
    var outputs: OWSpacerCellViewModelingOutputs { get }
}

class OWSpacerCellViewModel: OWSpacerCellViewModeling, OWSpacerCellViewModelingInputs, OWSpacerCellViewModelingOutputs {
    var inputs: OWSpacerCellViewModelingInputs { return self }
    var outputs: OWSpacerCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWSpacerCellViewModel {
    static func stub() -> OWSpacerCellViewModeling {
        return OWSpacerCellViewModel()
    }
}
