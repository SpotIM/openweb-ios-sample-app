//
//  LoadingCellVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 18/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWLoadingCellViewModelingInputs { }

protocol OWLoadingCellViewModelingOutputs {
    var id: String { get }
}

protocol OWLoadingCellViewModeling: OWCellViewModel {
    var inputs: OWLoadingCellViewModelingInputs { get }
    var outputs: OWLoadingCellViewModelingOutputs { get }
}

class OWLoadingCellViewModel: OWLoadingCellViewModeling,
                              OWLoadingCellViewModelingInputs,
                              OWLoadingCellViewModelingOutputs {
    var inputs: OWLoadingCellViewModelingInputs { return self }
    var outputs: OWLoadingCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWLoadingCellViewModel {
    static func stub() -> OWLoadingCellViewModeling {
        return OWLoadingCellViewModel()
    }
}
