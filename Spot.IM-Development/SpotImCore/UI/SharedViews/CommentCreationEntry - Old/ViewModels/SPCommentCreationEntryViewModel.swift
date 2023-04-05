//
//  OWCommentCreationViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol SPCommentCreationEntryViewModelingInputs {
    // TODO: configure functions should be removed from protocol once refactor complete
    func configure(user: SPUser)
    func configure(ctaText: String)
    func configure(delegate: SPCommentCreationEntryViewDelegate?)

    var tap: PublishSubject<Void> { get }
}

protocol SPCommentCreationEntryViewModelingOutputs {
    var avatarViewVM: OWAvatarViewModeling { get }
    var ctaText: Observable<String> { get }
    var tapped: Observable<Void> { get }
}

protocol SPCommentCreationEntryViewModeling {
    var inputs: SPCommentCreationEntryViewModelingInputs { get }
    var outputs: SPCommentCreationEntryViewModelingOutputs { get }
}

// TODO: Old view model, should be deleted once new infra complete
class SPCommentCreationEntryViewModel: SPCommentCreationEntryViewModeling, SPCommentCreationEntryViewModelingInputs, SPCommentCreationEntryViewModelingOutputs {

    var inputs: SPCommentCreationEntryViewModelingInputs { return self }
    var outputs: SPCommentCreationEntryViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    internal weak var delegate: SPCommentCreationEntryViewDelegate?

    var imageURLProvider: SPImageProvider?

    init (imageURLProvider: SPImageProvider?) {
        self.imageURLProvider = imageURLProvider
        setupObservers()
    }

    fileprivate let _actionText = BehaviorSubject<String>(value: LocalizationManager.localizedString(key: "What do you think?"))

    func configure(delegate: SPCommentCreationEntryViewDelegate?) {
        self.delegate = delegate
    }

    var tap = PublishSubject<Void>()

    var tapped: Observable<Void> {
        tap
            .asObserver()
    }

    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(user: SPUserSessionHolder.session.user, imageURLProvider: imageURLProvider)
    }()

    func configure(user: SPUser) {
        outputs.avatarViewVM.inputs.configureUser(user: user)
    }

    func configure(ctaText: String) {
        _actionText.onNext(ctaText)
    }

    var ctaText: Observable<String> {
        _actionText.asObserver()
    }
}

fileprivate extension SPCommentCreationEntryViewModel {
    func setupObservers() {
        outputs.avatarViewVM.outputs.avatarTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.userAvatarDidTap()
        }).disposed(by: disposeBag)

        outputs.tapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.labelContainerDidTap()
        }).disposed(by: disposeBag)
    }
}
