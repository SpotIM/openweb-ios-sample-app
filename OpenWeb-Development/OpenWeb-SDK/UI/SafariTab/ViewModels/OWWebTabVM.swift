//
//  OWWebTabVM.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWWebTabViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var closeWebTabTapped: PublishSubject<Void> { get }
}

protocol OWWebTabViewModelingOutputs {
    var webTabViewVM: OWWebTabViewViewModeling { get }
    var screenLoaded: Observable<Void> { get }
    var closeWebTab: Observable<Void> { get }
}

protocol OWWebTabViewModeling {
    var inputs: OWWebTabViewModelingInputs { get }
    var outputs: OWWebTabViewModelingOutputs { get }
}

class OWWebTabViewModel: OWWebTabViewModeling, OWWebTabViewModelingInputs, OWWebTabViewModelingOutputs {
    var inputs: OWWebTabViewModelingInputs { return self }
    var outputs: OWWebTabViewModelingOutputs { return self }

    fileprivate let options: OWWebTabOptions
    fileprivate let viewableMode: OWViewableMode

    lazy var webTabViewVM: OWWebTabViewViewModeling = {
        return OWWebTabViewViewModel(options: options,
                                     viewableMode: viewableMode)
    }()

    var closeWebTabTapped = PublishSubject<Void>()
    var closeWebTab: Observable<Void> {
        closeWebTabTapped
            .asObservable()
    }

    var viewDidLoad = PublishSubject<Void>()
    var screenLoaded: Observable<Void> {
        viewDidLoad.asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode
    }
}
