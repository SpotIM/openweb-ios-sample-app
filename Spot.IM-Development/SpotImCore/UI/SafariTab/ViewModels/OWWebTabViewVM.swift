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
    var canGoBack: PublishSubject<Bool> { get }
    var backWebTabTapped: PublishSubject<Void> { get }
    var setTitle: PublishSubject<String?> { get }
}

protocol OWWebTabViewViewModelingOutputs {
    var closeTapped: Observable<Void> { get }
    var backTapped: Observable<Void> { get }
    var viewableMode: OWViewableMode { get }
    var options: OWWebTabOptions { get }
    var titleViewVM: OWTitleViewViewModeling { get }
    var shouldShowTitleView: Bool { get }
    var shouldShowCloseButton: Observable<Bool> { get }
    var shouldShowBackButton: Observable<Bool> { get }
}

protocol OWWebTabViewViewModeling {
    var inputs: OWWebTabViewViewModelingInputs { get }
    var outputs: OWWebTabViewViewModelingOutputs { get }
}

class OWWebTabViewViewModel: OWWebTabViewViewModeling,
                             OWWebTabViewViewModelingInputs,
                             OWWebTabViewViewModelingOutputs {
    var inputs: OWWebTabViewViewModelingInputs { return self }
    var outputs: OWWebTabViewViewModelingOutputs { return self }

    let options: OWWebTabOptions
    let viewableMode: OWViewableMode

    let canGoBack = PublishSubject<Bool>()
    let setTitle = PublishSubject<String?>()

    let backWebTabTapped = PublishSubject<Void>()
    var backTapped: Observable<Void> {
        backWebTabTapped
            .asObservable()
    }

    var closeTapped: Observable<Void> {
        titleViewVM
            .outputs
            .closeTapped
            .asObservable()
    }

    var shouldShowCloseButton: Observable<Bool> {
        canGoBack
            .asObservable()
    }

    var shouldShowBackButton: Observable<Bool> {
        canGoBack
            .asObservable()
    }

    lazy var shouldShowTitleView: Bool = {
        return viewableMode == .independent
    }()

    lazy var titleViewVM: OWTitleViewViewModeling = {
        return OWTitleViewViewModel()
    }()

    fileprivate let disposeBag = DisposeBag()

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode

        setupObservers()
    }
}

extension OWWebTabViewViewModel {
    func setupObservers() {
        canGoBack
            .subscribe(onNext: { [weak self] canGoBack in
                guard let self = self else { return }
                self.titleViewVM.inputs.canGoBack.onNext(canGoBack)
            })
            .disposed(by: disposeBag)

        titleViewVM.outputs
            .backTapped
            .subscribe(onNext: { [weak self] canGoBack in
                guard let self = self else { return }
                self.backWebTabTapped.onNext()
            })
            .disposed(by: disposeBag)
    }
}
