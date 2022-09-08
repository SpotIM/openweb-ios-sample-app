//
//  OWConversationVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationViewModelingInputs {
    
}

protocol OWConversationViewModelingOutputs {
    var conversationViewVM: OWConversationViewViewModeling { get }
}

protocol OWConversationViewModeling {
    var inputs: OWConversationViewModelingInputs { get }
    var outputs: OWConversationViewModelingOutputs { get }
}

class OWConversationViewModel: OWConversationViewModeling, OWConversationViewModelingInputs, OWConversationViewModelingOutputs {
    var inputs: OWConversationViewModelingInputs { return self }
    var outputs: OWConversationViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    
    lazy var conversationViewVM: OWConversationViewViewModeling = {
        return OWConversationViewViewModel(conversationData: conversationData)
    }()

    init (conversationData: OWConversationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        setupObservers()
    }
}

fileprivate extension OWConversationViewModel {
    func setupObservers() {
        
    }
}
