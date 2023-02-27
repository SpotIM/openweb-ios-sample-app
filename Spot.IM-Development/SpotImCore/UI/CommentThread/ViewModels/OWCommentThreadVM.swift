//
//  OWCommentThreadVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWCommentThreadViewModelingOutputs {
    var commentThreadViewVM: OWCommentThreadViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
}

protocol OWCommentThreadViewModeling {
    var inputs: OWCommentThreadViewModelingInputs { get }
    var outputs: OWCommentThreadViewModelingOutputs { get }
}

class OWCommentThreadViewModel: OWCommentThreadViewModeling, OWCommentThreadViewModelingInputs, OWCommentThreadViewModelingOutputs {
    var inputs: OWCommentThreadViewModelingInputs { return self }
    var outputs: OWCommentThreadViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    lazy var commentThreadViewVM: OWCommentThreadViewViewModeling = {
        return OWCommentThreadViewViewModel(servicesProvider: self.servicesProvider)
    }()

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWCommentThreadViewModel {
    func setupObservers() {

    }
}
