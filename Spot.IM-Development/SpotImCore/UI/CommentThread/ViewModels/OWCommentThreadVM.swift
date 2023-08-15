//
//  OWCommentThreadVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var changeIsLargeTitleDisplay: PublishSubject<Bool> { get }
}

protocol OWCommentThreadViewModelingOutputs {
    var commentThreadViewVM: OWCommentThreadViewViewModeling { get }
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

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentThreadData: OWCommentThreadRequiredData

    lazy var commentThreadViewVM: OWCommentThreadViewViewModeling = {
        return OWCommentThreadViewViewModel(commentThreadData: commentThreadData, servicesProvider: self.servicesProvider,
                                            viewableMode: .partOfFlow)
    }()

    lazy var title: String = {
        return OWLocalizationManager.shared.localizedString(key: "Replies")
    }()

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    fileprivate lazy var _isLargeTitleDisplay: BehaviorSubject<Bool> = {
        return BehaviorSubject<Bool>(value: servicesProvider.navigationControllerCustomizer().isLargeTitlesEnabled())
    }()

    var changeIsLargeTitleDisplay = PublishSubject<Bool>()
    var isLargeTitleDisplay: Observable<Bool> {
        return _isLargeTitleDisplay
    }

    init (commentThreadData: OWCommentThreadRequiredData, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentThreadData = commentThreadData
        setupObservers()
    }
}

fileprivate extension OWCommentThreadViewModel {
    func setupObservers() {
        changeIsLargeTitleDisplay
            .bind(to: _isLargeTitleDisplay)
            .disposed(by: disposeBag)
    }
}
