//
//  OWConversationViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationViewViewModelingInputs {
    
}

protocol OWConversationViewViewModelingOutputs {
    
}

protocol OWConversationViewViewModeling {
    var inputs: OWConversationViewViewModelingInputs { get }
    var outputs: OWConversationViewViewModelingOutputs { get }
}

class OWConversationViewViewModel: OWConversationViewViewModeling, OWConversationViewViewModelingInputs, OWConversationViewViewModelingOutputs {
    var inputs: OWConversationViewViewModelingInputs { return self }
    var outputs: OWConversationViewViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWConversationViewViewModel {
    func setupObservers() {
        
    }
}
