//
//  OWReplyViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReplyViewModelingInputs {
    
}

protocol OWReplyViewModelingOutputs {
    
}

protocol OWReplyViewModeling: OWCellViewModel {
    var inputs: OWReplyViewModelingInputs { get }
    var outputs: OWReplyViewModelingOutputs { get }
}

class OWReplyViewModel: OWReplyViewModeling, OWReplyViewModelingInputs, OWReplyViewModelingOutputs {
    var inputs: OWReplyViewModelingInputs { return self }
    var outputs: OWReplyViewModelingOutputs { return self }
}

extension OWReplyViewModel {
    static func stub() -> OWReplyViewModeling {
        return OWReplyViewModel()
    }
}
