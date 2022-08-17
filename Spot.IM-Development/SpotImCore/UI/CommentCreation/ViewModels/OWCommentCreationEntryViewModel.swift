//
//  OWCommentCreationViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationEntryViewModelingInputs {

}

protocol OWCommentCreationEntryViewModelingOutputs {

}

protocol OWCommentCreationEntryViewModeling {
    var inputs: OWCommentCreationEntryViewModelingInputs { get }
    var outputs: OWCommentCreationEntryViewModelingOutputs { get }
}

class OWCommentCreationEntryViewModel: OWCommentCreationEntryViewModeling, OWCommentCreationEntryViewModelingInputs, OWCommentCreationEntryViewModelingOutputs {
    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    
    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWCommentCreationEntryViewModel {
    func setupObservers() {
        
    }
}
