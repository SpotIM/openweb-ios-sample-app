//
//  OWCommentCreationViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 17/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationEntryViewModelingInputs {
    func configure(user: SPUser)
    func configure(ctaText: String)
    func configure(delegate: OWCommentCreationEntryViewDelegate?)
    
    var tap: PublishSubject<Void> { get }
}

protocol OWCommentCreationEntryViewModelingOutputs {
    var avatarViewVM: OWAvatarViewModeling { get }
    var ctaText: Observable<String> { get }
    var tapped: Observable<Void> { get }
}

protocol OWCommentCreationEntryViewModeling {
    var inputs: OWCommentCreationEntryViewModelingInputs { get }
    var outputs: OWCommentCreationEntryViewModelingOutputs { get }
}

// TODO: Old view model, should be deleted once new infra complete
class OWCommentCreationEntryViewModel: OWCommentCreationEntryViewModeling, OWCommentCreationEntryViewModelingInputs, OWCommentCreationEntryViewModelingOutputs {
    
    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    internal weak var delegate: OWCommentCreationEntryViewDelegate?
    
    var imageURLProvider: SPImageProvider?
    
    init (imageURLProvider: SPImageProvider?) {
        self.imageURLProvider = imageURLProvider
        setupObservers()
    }
    
    fileprivate let _actionText = BehaviorSubject<String>(value: LocalizationManager.localizedString(key: "What do you think?"))
    
    func configure(delegate: OWCommentCreationEntryViewDelegate?) {
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

fileprivate extension OWCommentCreationEntryViewModel {
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

// TODO: View Model for new infra. Old one should be deleted
class OWCommentCreationEntryViewModelNew: OWCommentCreationEntryViewModeling, OWCommentCreationEntryViewModelingInputs, OWCommentCreationEntryViewModelingOutputs {
    
    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    var imageURLProvider: SPImageProvider?
    
    init (imageURLProvider: SPImageProvider?) {
        self.imageURLProvider = imageURLProvider
        setupObservers()
    }
    
    fileprivate let _actionText = BehaviorSubject<String>(value: LocalizationManager.localizedString(key: "What do you think?"))
    
    var tap = PublishSubject<Void>()
    
    var tapped: Observable<Void> {
        tap
            .asObserver()
    }
    
    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(user: SPUserSessionHolder.session.user, imageURLProvider: imageURLProvider)
    }()
    
    var ctaText: Observable<String> {
        _actionText.asObserver()
    }
    
    // TODO: configure functions should be removed from protocol once refactor complete
    func configure(user: SPUser) {
    }
    
    func configure(ctaText: String) {
    }
    
    func configure(delegate: OWCommentCreationEntryViewDelegate?) {
    }
}

fileprivate extension OWCommentCreationEntryViewModelNew {
    func setupObservers() {
        outputs.avatarViewVM.outputs.avatarTapped.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
//            self.delegate?.userAvatarDidTap()
        }).disposed(by: disposeBag)
    }
}
