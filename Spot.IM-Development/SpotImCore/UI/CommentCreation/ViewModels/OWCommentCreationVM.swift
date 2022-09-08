//
//  OWCommentCreationVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationViewModelingInputs {
    
}

protocol OWCommentCreationViewModelingOutputs {
    var commentCreationViewVM: OWCommentCreationViewViewModeling { get }
}

protocol OWCommentCreationViewModeling {
    var inputs: OWCommentCreationViewModelingInputs { get }
    var outputs: OWCommentCreationViewModelingOutputs { get }
}

class OWCommentCreationViewModel: OWCommentCreationViewModeling, OWCommentCreationViewModelingInputs, OWCommentCreationViewModelingOutputs {
    var inputs: OWCommentCreationViewModelingInputs { return self }
    var outputs: OWCommentCreationViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    lazy var commentCreationViewVM: OWCommentCreationViewViewModeling = {
        return OWCommentCreationViewViewModel()
    }()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWCommentCreationViewModel {
    func setupObservers() {
        
    }
}
