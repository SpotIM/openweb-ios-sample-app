//
//  OWReplyCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReplyCellViewModelingInputs {
    
}

protocol OWReplyCellViewModelingOutputs {
    
}

protocol OWReplyCellViewModeling: OWCellViewModel {
    var inputs: OWReplyCellViewModelingInputs { get }
    var outputs: OWReplyCellViewModelingOutputs { get }
}

class OWReplyCellViewModel: OWReplyCellViewModeling, OWReplyCellViewModelingInputs, OWReplyCellViewModelingOutputs {
    var inputs: OWReplyCellViewModelingInputs { return self }
    var outputs: OWReplyCellViewModelingOutputs { return self }
}

extension OWReplyCellViewModel {
    static func stub() -> OWReplyCellViewModeling {
        return OWReplyCellViewModel()
    }
}
