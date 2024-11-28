//
//  OWCommentThreadVM.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var changeIsLargeTitleDisplay: PublishSubject<Bool> { get }
}

protocol OWCommentThreadViewModelingOutputs {
    var commentThreadViewVM: any OWCommentThreadViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
    var title: String { get }
    var isLargeTitleDisplay: Observable<Bool> { get }
}

protocol OWCommentThreadViewModeling {
    var inputs: OWCommentThreadViewModelingInputs { get }
    var outputs: OWCommentThreadViewModelingOutputs { get }
}

class OWCommentThreadViewModel: OWCommentThreadViewModeling, OWCommentThreadViewModelingInputs, OWCommentThreadViewModelingOutputs {
    var inputs: OWCommentThreadViewModelingInputs { return self }
    var outputs: OWCommentThreadViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let servicesProvider: OWSharedServicesProviding
    private let commentThreadData: OWCommentThreadRequiredData
    private let viewableMode: OWViewableMode

    lazy var commentThreadViewVM: any OWCommentThreadViewViewModeling = {
        return OWCommentThreadViewViewModel(commentThreadData: commentThreadData,
                                            servicesProvider: self.servicesProvider,
                                            viewableMode: self.viewableMode)
    }()

    lazy var title: String = {
        return commentThreadViewVM.outputs.title
    }()

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    private lazy var _isLargeTitleDisplay: BehaviorSubject<Bool> = {
        return BehaviorSubject<Bool>(value: servicesProvider.navigationControllerCustomizer().isLargeTitlesEnabled())
    }()

    var changeIsLargeTitleDisplay = PublishSubject<Bool>()
    var isLargeTitleDisplay: Observable<Bool> {
        return _isLargeTitleDisplay
    }

    init (commentThreadData: OWCommentThreadRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentThreadData = commentThreadData
        self.viewableMode = viewableMode
        setupObservers()
    }
}

private extension OWCommentThreadViewModel {
    func setupObservers() {
        changeIsLargeTitleDisplay
            .bind(to: _isLargeTitleDisplay)
            .disposed(by: disposeBag)
    }
}
