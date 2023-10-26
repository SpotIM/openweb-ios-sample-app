//
//  OWFontsAutomationViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import Foundation

protocol OWFontsAutomationViewModelingInputs { }

protocol OWFontsAutomationViewModelingOutputs {
    var viewVM: OWFontsAutomationViewViewModeling { get }
    var title: String { get }
}

protocol OWFontsAutomationViewModeling {
    var inputs: OWFontsAutomationViewModelingInputs { get }
    var outputs: OWFontsAutomationViewModelingOutputs { get }
}

class OWFontsAutomationViewModel: OWFontsAutomationViewModeling,
                                OWFontsAutomationViewModelingInputs,
                                OWFontsAutomationViewModelingOutputs {
    var inputs: OWFontsAutomationViewModelingInputs { return self }
    var outputs: OWFontsAutomationViewModelingOutputs { return self }

    lazy var viewVM: OWFontsAutomationViewViewModeling = {
        return OWFontsAutomationViewViewModel()
    }()

    lazy var title: String = {
        return OWLocalizationManager.shared.localizedString(key: "Fonts")
    }()
}

#endif
