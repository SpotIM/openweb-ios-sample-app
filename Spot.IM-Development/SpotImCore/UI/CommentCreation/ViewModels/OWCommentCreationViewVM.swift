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
    var commentType: OWCommentCreationType { get }
    var commentCreationStyle: OWCommentCreationStyle { get }
}

protocol OWCommentCreationViewViewModeling {
    var inputs: OWCommentCreationViewViewModelingInputs { get }
    var outputs: OWCommentCreationViewViewModelingOutputs { get }
}

class OWCommentCreationViewViewModel: OWCommentCreationViewViewModeling, OWCommentCreationViewViewModelingInputs, OWCommentCreationViewViewModelingOutputs {
    var inputs: OWCommentCreationViewViewModelingInputs { return self }
    var outputs: OWCommentCreationViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationData: OWCommentCreationRequiredData

    lazy var commentType: OWCommentCreationType = {
        return self.commentCreationData.commentCreationType
    }()

    lazy var commentCreationStyle: OWCommentCreationStyle = {
        return self.commentCreationData.settings?.style ?? .regular
    }()

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        setupObservers()
    }
}

fileprivate extension OWCommentCreationViewViewModel {
    func setupObservers() {

    }
}
