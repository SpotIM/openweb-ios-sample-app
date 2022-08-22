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
    func configureUser(user: SPUser)
    func configureActionText(text: String)
    
    var tapAction: PublishSubject<Void> { get }
}

protocol OWCommentCreationEntryViewModelingOutputs {
    var avatarViewVM: OWAvatarViewModeling { get }
    var actionText: Observable<String> { get }
    var actionTapped: Observable<Void> { get }
}

protocol OWCommentCreationEntryViewModeling {
    var inputs: OWCommentCreationEntryViewModelingInputs { get }
    var outputs: OWCommentCreationEntryViewModelingOutputs { get }
}

class OWCommentCreationEntryViewModel: OWCommentCreationEntryViewModeling, OWCommentCreationEntryViewModelingInputs, OWCommentCreationEntryViewModelingOutputs {
    
    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }
    
    fileprivate let _actionText = BehaviorSubject<String>(value: LocalizationManager.localizedString(key: "What do you think?"))
    
    var imageURLProvider: SPImageProvider?
    
    init (imageURLProvider: SPImageProvider?) {
        self.imageURLProvider = imageURLProvider
        setupObservers()
    }
    
    var tapAction = PublishSubject<Void>()
    
    var actionTapped: Observable<Void> {
        tapAction
            .asObserver()
    }
    
    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(user: SPUserSessionHolder.session.user, imageURLProvider: imageURLProvider)
    }()
    
    func configureUser(user: SPUser) {
        outputs.avatarViewVM.inputs.configureUser(user: user)
    }
    
    func configureActionText(text: String) {
        _actionText.onNext(text)
    }
    
    var actionText: Observable<String> {
        _actionText.asObserver()
    }
}

fileprivate extension OWCommentCreationEntryViewModel {
    func setupObservers() {
        
    }
}
