//
//  OWTitleViewViewModel.swift
//  SpotImCore
//
//  Created by Refael Sommer on 29/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWTitleViewViewModelingInputs {
    var closeTap: PublishSubject<Void> { get }
    var backTap: PublishSubject<Void> { get }
    var canGoBack: PublishSubject<Bool> { get }
    var setTitle: PublishSubject<String?> { get }
}

protocol OWTitleViewViewModelingOutputs {
    var closeTapped: Observable<Void> { get }
    var backTapped: Observable<Void> { get }
    var shouldShowBackButton: Observable<Bool> { get }
    var title: Observable<String?> { get }
}

protocol OWTitleViewViewModeling {
    var inputs: OWTitleViewViewModelingInputs { get }
    var outputs: OWTitleViewViewModelingOutputs { get }
}

class OWTitleViewViewModel: OWTitleViewViewModeling, OWTitleViewViewModelingOutputs, OWTitleViewViewModelingInputs {
    var inputs: OWTitleViewViewModelingInputs { return self }
    var outputs: OWTitleViewViewModelingOutputs { return self }

    let setTitle = PublishSubject<String?>()
    var title: Observable<String?> {
        setTitle
            .asObservable()
    }

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        return closeTap
            .asObservable()
    }

    var backTap = PublishSubject<Void>()
    var backTapped: Observable<Void> {
        return backTap
            .asObservable()
    }

    let canGoBack = PublishSubject<Bool>()
    var shouldShowBackButton: Observable<Bool> {
        canGoBack
            .asObservable()
    }
}
