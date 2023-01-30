//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadViewViewModelingInputs {
    
}

protocol OWCommentThreadViewViewModelingOutputs {

}

protocol OWCommentThreadViewViewModeling {
    var inputs: OWCommentThreadViewViewModelingInputs { get }
    var outputs: OWCommentThreadViewViewModelingOutputs { get }
}

class OWCommentThreadViewViewModel: OWCommentThreadViewViewModeling, OWCommentThreadViewViewModelingInputs, OWCommentThreadViewViewModelingOutputs {
    var inputs: OWCommentThreadViewViewModelingInputs { return self }
    var outputs: OWCommentThreadViewViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    func setupObservers() {
        
    }
}
