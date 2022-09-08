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
    var userInitiatedAuthenticationFlow: Observable<Void> { get }
    var commentCreated: Observable<SPComment> { get }
}

protocol OWCommentCreationViewModeling {
    var inputs: OWCommentCreationViewModelingInputs { get }
    var outputs: OWCommentCreationViewModelingOutputs { get }
}

class OWCommentCreationViewModel: OWCommentCreationViewModeling, OWCommentCreationViewModelingInputs, OWCommentCreationViewModelingOutputs {
    var inputs: OWCommentCreationViewModelingInputs { return self }
    var outputs: OWCommentCreationViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationData: OWCommentCreationRequiredData

    lazy var commentCreationViewVM: OWCommentCreationViewViewModeling = {
        return OWCommentCreationViewViewModel(commentCreationData: commentCreationData)
    }()
    
    var userInitiatedAuthenticationFlow: Observable<Void> {
        // TODO: Complete
        return .never()
    }
    
    var commentCreated: Observable<SPComment> {
        // TODO: Complete
        return .never()
    }

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        setupObservers()
    }
}

fileprivate extension OWCommentCreationViewModel {
    func setupObservers() {
        
    }
}
