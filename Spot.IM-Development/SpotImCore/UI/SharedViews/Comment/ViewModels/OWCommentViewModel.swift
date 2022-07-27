//
//  OWCommentViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentViewModelingInputs {
    
}

protocol OWCommentViewModelingOutputs {
    
}

protocol OWCommentViewModeling: OWCellViewModel {
    var inputs: OWCommentViewModelingInputs { get }
    var outputs: OWCommentViewModelingOutputs { get }
}

class OWCommentViewModel: OWCommentViewModeling, OWCommentViewModelingInputs, OWCommentViewModelingOutputs {
    var inputs: OWCommentViewModelingInputs { return self }
    var outputs: OWCommentViewModelingOutputs { return self }
}

extension OWCommentViewModel {
    static func stub() -> OWCommentViewModeling {
        return OWCommentViewModel()
    }
}
