//
//  OWFontsAutomationViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import Foundation

protocol OWFontsAutomationViewViewModelingInputs { }

protocol OWFontsAutomationViewViewModelingOutputs { }

protocol OWFontsAutomationViewViewModeling {
    var inputs: OWFontsAutomationViewViewModelingInputs { get }
    var outputs: OWFontsAutomationViewViewModelingOutputs { get }
}

class OWFontsAutomationViewViewModel: OWFontsAutomationViewViewModeling,
                                OWFontsAutomationViewViewModelingInputs,
                                OWFontsAutomationViewViewModelingOutputs {
    var inputs: OWFontsAutomationViewViewModelingInputs { return self }
    var outputs: OWFontsAutomationViewViewModelingOutputs { return self }

}

#endif
