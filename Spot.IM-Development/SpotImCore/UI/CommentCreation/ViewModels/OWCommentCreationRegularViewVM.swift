//
//  OWCommentCreationRegularViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationRegularViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationRegularViewViewModelingOutputs {
    var commentType: OWCommentCreationType { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var footerViewModel: OWCommentCreationFooterViewModeling { get }
}

protocol OWCommentCreationRegularViewViewModeling {
    var inputs: OWCommentCreationRegularViewViewModelingInputs { get }
    var outputs: OWCommentCreationRegularViewViewModelingOutputs { get }
}

class OWCommentCreationRegularViewViewModel: OWCommentCreationRegularViewViewModeling, OWCommentCreationRegularViewViewModelingInputs, OWCommentCreationRegularViewViewModelingOutputs {
    var inputs: OWCommentCreationRegularViewViewModelingInputs { return self }
    var outputs: OWCommentCreationRegularViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationData: OWCommentCreationRequiredData

    var commentType: OWCommentCreationType

    var closeButtonTap = PublishSubject<Void>()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel(article: commentCreationData.article)
    }()

    lazy var footerViewModel: OWCommentCreationFooterViewModeling = {
        return OWCommentCreationFooterViewModel()
    }()

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        commentType = commentCreationData.commentCreationType
        setupObservers()
    }
}

fileprivate extension OWCommentCreationRegularViewViewModel {
    func setupObservers() {

    }
}
