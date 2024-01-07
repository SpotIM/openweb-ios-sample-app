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
    var closeWebTabTapped: PublishSubject<Void> { get }
    var backWebTabTapped: PublishSubject<Void> { get }
}

protocol OWWebTabViewModelingOutputs {
    var webTabViewVM: OWWebTabViewViewModeling { get }
    var screenLoaded: Observable<Void> { get }
    var options: OWWebTabOptions { get }
    var closeWebTab: Observable<Void> { get }
    var shouldShowCloseButton: Observable<Bool> { get }
    var shouldShowBackButton: Observable<Bool> { get }
    var title: Observable<String?> { get }
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

    var closeWebTabTapped = PublishSubject<Void>()
    var closeWebTab: Observable<Void> {
        closeWebTabTapped
            .asObservable()
    }

    var backWebTabTapped = PublishSubject<Void>()

    var viewDidLoad = PublishSubject<Void>()
    var screenLoaded: Observable<Void> {
        viewDidLoad.asObservable()
    }

    var shouldShowCloseButton: Observable<Bool> {
        webTabViewVM.outputs
            .shouldShowCloseButton
            .asObservable()
    }

    var shouldShowBackButton: Observable<Bool> {
        webTabViewVM.outputs
            .shouldShowBackButton
            .asObservable()
    }

    var title: Observable<String?> {
        webTabViewVM.inputs
            .setTitle
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode

        setupObservers()
    }
}

extension OWWebTabViewModel {
    func setupObservers() {
        backWebTabTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.webTabViewVM.inputs.backWebTabTapped.onNext()
            })
            .disposed(by: disposeBag)
    }
}
