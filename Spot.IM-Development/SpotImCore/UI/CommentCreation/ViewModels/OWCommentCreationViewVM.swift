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
    var commentCreationRegularViewVm: OWCommentCreationRegularViewViewModeling { get }
    var commentCreationLightViewVm: OWCommentCreationLightViewViewModeling { get }
    var commentCreationFloatingKeyboardViewVm: OWCommentCreationFloatingKeyboardViewViewModeling { get }
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

    lazy var commentCreationRegularViewVm: OWCommentCreationRegularViewViewModeling = {
        return OWCommentCreationRegularViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentCreationLightViewVm: OWCommentCreationLightViewViewModeling = {
        return OWCommentCreationLightViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentCreationFloatingKeyboardViewVm: OWCommentCreationFloatingKeyboardViewViewModeling = {
        return OWCommentCreationFloatingKeyboardViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentType: OWCommentCreationType = {
        return self.commentCreationData.commentCreationType
    }()

    lazy var commentCreationStyle: OWCommentCreationStyle = {
        return self.commentCreationData.settings.commentCreationSettings.style
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
