//
//  OWUserStatusAutomationViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import Foundation

protocol OWUserStatusAutomationViewViewModelingInputs { }

protocol OWUserStatusAutomationViewViewModelingOutputs { }

protocol OWUserStatusAutomationViewViewModeling {
    var inputs: OWUserStatusAutomationViewViewModelingInputs { get }
    var outputs: OWUserStatusAutomationViewViewModelingOutputs { get }
}

class OWUserStatusAutomationViewViewModel: OWUserStatusAutomationViewViewModeling,
                                OWUserStatusAutomationViewViewModelingInputs,
                                OWUserStatusAutomationViewViewModelingOutputs {
    var inputs: OWUserStatusAutomationViewViewModelingInputs { return self }
    var outputs: OWUserStatusAutomationViewViewModelingOutputs { return self }

}

#endif
