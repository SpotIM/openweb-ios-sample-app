//
//  OWSafariTabVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSafariTabViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWSafariTabViewModelingOutputs {
    var safariTabViewVM: OWSafariTabViewViewModeling { get }
    var screenLoaded: Observable<Void> { get }
    var options: OWSafariTabOptions { get }
}

protocol OWSafariTabViewModeling {
    var inputs: OWSafariTabViewModelingInputs { get }
    var outputs: OWSafariTabViewModelingOutputs { get }
}

class OWSafariTabViewModel: OWSafariTabViewModeling, OWSafariTabViewModelingInputs, OWSafariTabViewModelingOutputs {
    var inputs: OWSafariTabViewModelingInputs { return self }
    var outputs: OWSafariTabViewModelingOutputs { return self }

    let options: OWSafariTabOptions
    fileprivate let viewableMode: OWViewableMode

    lazy var safariTabViewVM: OWSafariTabViewViewModeling = {
        return OWSafariTabViewViewModel(options: options,
                                        viewableMode: self.viewableMode)
    }()

    var viewDidLoad = PublishSubject<Void>()
    var screenLoaded: Observable<Void> {
        viewDidLoad.asObservable()
    }

    init(options: OWSafariTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode
    }
}
