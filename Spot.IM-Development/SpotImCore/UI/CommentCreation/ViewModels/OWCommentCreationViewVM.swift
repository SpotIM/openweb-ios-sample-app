//
//  OWCommentCreationViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationViewViewModelingInputs {
    
}

protocol OWCommentCreationViewViewModelingOutputs {
    var replyToComment: Observable<SPComment?> { get }
}

protocol OWCommentCreationViewViewModeling {
    var inputs: OWCommentCreationViewViewModelingInputs { get }
    var outputs: OWCommentCreationViewViewModelingOutputs { get }
}

class OWCommentCreationViewViewModel: OWCommentCreationViewViewModeling, OWCommentCreationViewViewModelingInputs, OWCommentCreationViewViewModelingOutputs {
    var inputs: OWCommentCreationViewViewModelingInputs { return self }
    var outputs: OWCommentCreationViewViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentCreationData = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)
    
    var replyToComment: Observable<SPComment?> {
        _commentCreationData
            .unwrap()
            .map {
                switch $0.commentCreationType {
                case .comment:
                    return nil
                case .replyToComment(let originComment):
                    return originComment
                }
            }
            .asObservable()
    }

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self._commentCreationData.onNext(commentCreationData)
        setupObservers()
    }
}

fileprivate extension OWCommentCreationViewViewModel {
    func setupObservers() {
        
    }
}
