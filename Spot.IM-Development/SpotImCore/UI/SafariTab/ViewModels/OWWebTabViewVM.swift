//
//  OWWebTabViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 02/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWWebTabViewViewModelingInputs {
    var closeTap: PublishSubject<Void> { get }
}

protocol OWWebTabViewViewModelingOutputs {
    var closeTapped: Observable<Void> { get }
    var viewableMode: OWViewableMode { get }
    var options: OWWebTabOptions { get }
}

protocol OWWebTabViewViewModeling {
    var inputs: OWWebTabViewViewModelingInputs { get }
    var outputs: OWWebTabViewViewModelingOutputs { get }
}

class OWWebTabViewViewModel: OWWebTabViewViewModeling, OWWebTabViewViewModelingInputs, OWWebTabViewViewModelingOutputs {
    var inputs: OWWebTabViewViewModelingInputs { return self }
    var outputs: OWWebTabViewViewModelingOutputs { return self }

    let options: OWWebTabOptions
    let viewableMode: OWViewableMode

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        closeTap
            .asObservable()
    }

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode
    }
}
