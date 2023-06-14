//
//  OWCommentCreationLightViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationLightViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationLightViewViewModelingOutputs {
    var commentType: OWCommentCreationType { get }
}

protocol OWCommentCreationLightViewViewModeling {
    var inputs: OWCommentCreationLightViewViewModelingInputs { get }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { get }
}

class OWCommentCreationLightViewViewModel: OWCommentCreationLightViewViewModeling, OWCommentCreationLightViewViewModelingInputs, OWCommentCreationLightViewViewModelingOutputs {
    var inputs: OWCommentCreationLightViewViewModelingInputs { return self }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentCreationData = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)

    var commentType: OWCommentCreationType

    var closeButtonTap = PublishSubject<Void>()

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self._commentCreationData.onNext(commentCreationData)
        commentType = commentCreationData.commentCreationType
        setupObservers()
    }
}

fileprivate extension OWCommentCreationLightViewViewModel {
    func setupObservers() {

    }
}
