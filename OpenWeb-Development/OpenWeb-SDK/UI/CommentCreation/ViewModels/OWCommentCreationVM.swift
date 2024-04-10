//
//  OWCommentCreationVM.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationViewModelingInputs {
    var viewDidLoad: BehaviorSubject<Void?> { get }
}

protocol OWCommentCreationViewModelingOutputs {
    var commentCreationViewVM: OWCommentCreationViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
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
    fileprivate let viewableMode: OWViewableMode

    lazy var commentCreationViewVM: OWCommentCreationViewViewModeling = {
        return OWCommentCreationViewViewModel(commentCreationData: commentCreationData,
                                              viewableMode: viewableMode)
    }()

    var viewDidLoad = BehaviorSubject<Void?>(value: nil)
    var loadedToScreen: Observable<Void> {
        return viewDidLoad
            .unwrap()
            .asObservable()
    }

    init(commentCreationData: OWCommentCreationRequiredData,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        self.viewableMode = viewableMode
        setupObservers()
    }
}

fileprivate extension OWCommentCreationViewModel {
    func setupObservers() {

    }
}
