//
//  OWCommentCellViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCellViewModelingInputs {
    
}

protocol OWCommentCellViewModelingOutputs {
    
}

protocol OWCommentCellViewModeling: OWCellViewModel {
    var inputs: OWCommentCellViewModelingInputs { get }
    var outputs: OWCommentCellViewModelingOutputs { get }
}

class OWCommentCellViewModel: OWCommentCellViewModeling, OWCommentCellViewModelingInputs, OWCommentCellViewModelingOutputs {
    var inputs: OWCommentCellViewModelingInputs { return self }
    var outputs: OWCommentCellViewModelingOutputs { return self }
}

extension OWCommentCellViewModel {
    static func stub() -> OWCommentCellViewModeling {
        return OWCommentCellViewModel()
    }
}
