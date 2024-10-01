//
//  OWWebTabViewVM.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 02/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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
    var title: Observable<String?> { get }
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

    let canGoBack = PublishSubject<Bool>()
    var shouldShowCloseButton: Observable<Bool> {
        canGoBack
            .asObservable()
    }

    var shouldShowBackButton: Observable<Bool> {
        canGoBack
            .asObservable()
    }

    let setTitle = PublishSubject<String?>()
    var title: Observable<String?> {
        setTitle
            .asObservable()
    }

    lazy var shouldShowTitleView: Bool = {
        return viewableMode == .independent
    }()

    lazy var titleViewVM: OWTitleViewViewModeling = {
        return OWTitleViewViewModel()
    }()

    private let disposeBag = DisposeBag()

    init(options: OWWebTabOptions, viewableMode: OWViewableMode) {
        self.options = options
        self.viewableMode = viewableMode

        self.setTitle.onNext(options.title)

        setupObservers()
    }
}

extension OWWebTabViewViewModel {
    func setupObservers() {
        canGoBack
            .bind(to: titleViewVM.inputs.canGoBack)
            .disposed(by: disposeBag)

        titleViewVM.outputs
            .backTapped
            .bind(to: backWebTabTapped)
            .disposed(by: disposeBag)

        setTitle
            .bind(to: titleViewVM.inputs.setTitle)
            .disposed(by: disposeBag)
    }
}
