//
//  OWSafariViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSafariViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWSafariViewModelingOutputs {
    var options: OWSafariViewControllerOptions { get }
    var screenLoaded: Observable<Void> { get }
}

protocol OWSafariViewModeling {
    var inputs: OWSafariViewModelingInputs { get }
    var outputs: OWSafariViewModelingOutputs { get }
}

class OWSafariViewModel: OWSafariViewModeling, OWSafariViewModelingInputs, OWSafariViewModelingOutputs {
    var inputs: OWSafariViewModelingInputs { return self }
    var outputs: OWSafariViewModelingOutputs { return self }

    var options: OWSafariViewControllerOptions

    var viewDidLoad = PublishSubject<Void>()
    var screenLoaded: Observable<Void> {
        viewDidLoad.asObservable()
    }

    init(options: OWSafariViewControllerOptions) {
        self.options = options
    }
}
