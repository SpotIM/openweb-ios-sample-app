//
//  OWLoginPromptViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 17/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWLoginPromptViewModelingInputs { }

protocol OWLoginPromptViewModelingOutputs { }

protocol OWLoginPromptViewModeling {
    var inputs: OWLoginPromptViewModelingInputs { get }
    var outputs: OWLoginPromptViewModelingOutputs { get }
}

class OWLoginPromptViewModel: OWLoginPromptViewModeling,
                              OWLoginPromptViewModelingInputs,
                              OWLoginPromptViewModelingOutputs {

    var inputs: OWLoginPromptViewModelingInputs { return self }
    var outputs: OWLoginPromptViewModelingOutputs { return self }
}
