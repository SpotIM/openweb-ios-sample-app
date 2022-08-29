//
//  OWPreConversationVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationViewModelingInputs {
    
}

protocol OWPreConversationViewModelingOutputs {
    var preConversationViewVM: OWPreConversationViewViewModeling { get }
}

protocol OWPreConversationViewModeling {
    var inputs: OWPreConversationViewModelingInputs { get }
    var outputs: OWPreConversationViewModelingOutputs { get }
}

class OWPreConversationViewModel: OWPreConversationViewModeling, OWPreConversationViewModelingInputs, OWPreConversationViewModelingOutputs {
    var inputs: OWPreConversationViewModelingInputs { return self }
    var outputs: OWPreConversationViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    lazy var preConversationViewVM: OWPreConversationViewViewModeling = {
        return OWPreConversationViewViewModel()
    }()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWPreConversationViewModel {
    func setupObservers() {
        
    }
}
