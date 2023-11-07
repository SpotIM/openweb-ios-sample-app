//
//  OWWebTabVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWWebTabViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWWebTabViewModelingOutputs {
    var webTabViewVM: OWWebTabViewViewModeling { get }
    var screenLoaded: Observable<Void> { get }
    var options: OWWebTabOptions { get }
}

protocol OWWebTabViewModeling {
    var inputs: OWWebTabViewModelingInputs { get }
    var outputs: OWWebTabViewModelingOutputs { get }
}

class OWWebTabViewModel: OWWebTabViewModeling, OWWebTabViewModelingInputs, OWWebTabViewModelingOutputs {
    var inputs: OWWebTabViewModelingInputs { return self }
    var outputs: OWWebTabViewModelingOutputs { return self }

    let options: OWWebTabOptions
    fileprivate let viewableMode: OWViewableMode

    lazy var webTabViewVM: OWWebTabViewViewModeling = {
        return OWWebTabViewViewModel(options: options,
                                        viewableMode: self.viewableMode)
    }()

    var viewDidLoad = PublishSubject<Void>()
    var screenLoaded: Observable<Void> {
        viewDidLoad.asObservable()
    }

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode
    }
}
