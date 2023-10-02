//
//  OWSafariTabViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 02/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSafariTabViewViewModelingInputs {
    var closeTap: PublishSubject<Void> { get }
}

protocol OWSafariTabViewViewModelingOutputs {
    var closeTapped: Observable<Void> { get }
    var viewableMode: OWViewableMode { get }
    var options: OWSafariTabOptions { get }
}

protocol OWSafariTabViewViewModeling {
    var inputs: OWSafariTabViewViewModelingInputs { get }
    var outputs: OWSafariTabViewViewModelingOutputs { get }
}

class OWSafariTabViewViewModel: OWSafariTabViewViewModeling, OWSafariTabViewViewModelingInputs, OWSafariTabViewViewModelingOutputs {
    var inputs: OWSafariTabViewViewModelingInputs { return self }
    var outputs: OWSafariTabViewViewModelingOutputs { return self }

    let options: OWSafariTabOptions
    let viewableMode: OWViewableMode

    var closeTap = PublishSubject<Void>()
    var closeTapped: Observable<Void> {
        closeTap
            .asObservable()
    }

    init(options: OWSafariTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode
    }
}
