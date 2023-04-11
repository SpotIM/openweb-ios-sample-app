//
//  OWCommentCreationViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationEntryViewModelingInputs {
    var tap: PublishSubject<Void> { get }
}

protocol OWCommentCreationEntryViewModelingOutputs {
    var avatarViewVM: OWAvatarViewModeling { get }
    var tapped: Observable<Void> { get }
}

protocol OWCommentCreationEntryViewModeling {
    var inputs: OWCommentCreationEntryViewModelingInputs { get }
    var outputs: OWCommentCreationEntryViewModelingOutputs { get }
}

class OWCommentCreationEntryViewModel: OWCommentCreationEntryViewModeling, OWCommentCreationEntryViewModelingInputs, OWCommentCreationEntryViewModelingOutputs {

    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var imageURLProvider: OWImageProviding
    var sharedServiceProvider: OWSharedServicesProviding

    init (imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(), sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.imageURLProvider = imageURLProvider
        self.sharedServiceProvider = sharedServiceProvider
        setupObservers()
    }

    var tap = PublishSubject<Void>()

    var tapped: Observable<Void> {
        tap
            .asObserver()
    }

    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(backgroundColor: .backgroundColor2, imageURLProvider: imageURLProvider)
    }()
}

fileprivate extension OWCommentCreationEntryViewModel {
    func setupObservers() {
        sharedServiceProvider.authenticationManager()
            .activeUserAvailability
            .subscribe(onNext: { [weak self] availability in
                guard let self = self else { return }
                switch (availability) {
                case .notAvailable:
                    self.avatarViewVM.inputs.userInput.onNext(nil)
                case .user(let user):
                    self.avatarViewVM.inputs.userInput.onNext(user)
                }
            })
            .disposed(by: disposeBag)

        // TODO: should set the avatar viewModel according to the current connected user (not in infra yet)
        // TODO: open current user profile on click (once current user infra is ready)
        outputs.avatarViewVM.outputs.avatarTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//            self.delegate?.userAvatarDidTap()
        }).disposed(by: disposeBag)
    }
}
