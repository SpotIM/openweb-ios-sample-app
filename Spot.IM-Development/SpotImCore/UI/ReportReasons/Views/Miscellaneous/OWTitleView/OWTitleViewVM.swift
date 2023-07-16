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
}

protocol OWTitleViewViewModelingOutputs {
    var closeTapped: Observable<Void> { get }
}

protocol OWTitleViewViewModeling {
    var inputs: OWTitleViewViewModelingInputs { get }
    var outputs: OWTitleViewViewModelingOutputs { get }
}

class OWTitleViewViewModel: OWTitleViewViewModeling, OWTitleViewViewModelingOutputs, OWTitleViewViewModelingInputs {
    var inputs: OWTitleViewViewModelingInputs { return self }
    var outputs: OWTitleViewViewModelingOutputs { return self }

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        return closeTap.asObservable()
    }
}
