//
//  OWUserStatusAutomationViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import Foundation

protocol OWUserStatusAutomationViewModelingInputs { }

protocol OWUserStatusAutomationViewModelingOutputs {
    var viewVM: OWUserStatusAutomationViewViewModeling { get }
    var title: String { get }
}

protocol OWUserStatusAutomationViewModeling {
    var inputs: OWUserStatusAutomationViewModelingInputs { get }
    var outputs: OWUserStatusAutomationViewModelingOutputs { get }
}

class OWUserStatusAutomationViewModel: OWUserStatusAutomationViewModeling,
                                OWUserStatusAutomationViewModelingInputs,
                                OWUserStatusAutomationViewModelingOutputs {
    var inputs: OWUserStatusAutomationViewModelingInputs { return self }
    var outputs: OWUserStatusAutomationViewModelingOutputs { return self }

    lazy var viewVM: OWUserStatusAutomationViewViewModeling = {
        return OWUserStatusAutomationViewViewModel()
    }()

    lazy var title: String = {
        return OWLocalizationManager.shared.localizedString(key: "UserInformation")
    }()
}

#endif
