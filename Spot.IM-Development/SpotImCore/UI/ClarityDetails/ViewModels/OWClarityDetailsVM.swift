//
//  OWClarityDetailsVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWClarityDetailsViewModelingInputs { }

protocol OWClarityDetailsViewModelingOutputs {
    var clarityDetailsViewViewModel: OWClarityDetailsViewViewModeling { get }
}

protocol OWClarityDetailsViewModeling {
    var inputs: OWClarityDetailsViewModelingInputs { get }
    var outputs: OWClarityDetailsViewModelingOutputs { get }
}

class OWClarityDetailsVM: OWClarityDetailsViewModeling,
                                 OWClarityDetailsViewModelingInputs,
                          OWClarityDetailsViewModelingOutputs {

    var inputs: OWClarityDetailsViewModelingInputs { return self }
    var outputs: OWClarityDetailsViewModelingOutputs { return self }

    lazy var clarityDetailsViewViewModel: OWClarityDetailsViewViewModeling = {
        return OWClarityDetailsViewVM() // TODO: pass type
    }()

    init(viewableMode: OWViewableMode) {
        // TODO: viewable mode for navigation title
    }
}


