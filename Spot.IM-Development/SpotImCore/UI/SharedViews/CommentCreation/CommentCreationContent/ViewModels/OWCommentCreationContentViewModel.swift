//
//  OWCommentCreationContentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationContentViewModelingInputs {
    var commentText: BehaviorSubject<String?> { get }
}

protocol OWCommentCreationContentViewModelingOutputs {
    var commentTextOutput: Observable<String?> { get }
    var showPlaceholder: Observable<Bool> { get }
    var avatarViewVM: OWAvatarViewModeling { get }
}

protocol OWCommentCreationContentViewModeling {
    var inputs: OWCommentCreationContentViewModelingInputs { get }
    var outputs: OWCommentCreationContentViewModelingOutputs { get }
}

class OWCommentCreationContentViewModel: OWCommentCreationContentViewModeling,
                                         OWCommentCreationContentViewModelingInputs,
                                         OWCommentCreationContentViewModelingOutputs {

    var inputs: OWCommentCreationContentViewModelingInputs { return self }
    var outputs: OWCommentCreationContentViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let imageURLProvider: OWImageProviding
    fileprivate let servicesProvider: OWSharedServicesProviding

    var commentText = BehaviorSubject<String?>(value: nil)

    lazy var avatarViewVM: OWAvatarViewModeling = {
        OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    var commentTextOutput: Observable<String?> {
        commentText
            .asObservable()
    }

    var showPlaceholder: Observable<Bool> {
        commentTextOutput
            .map { ($0?.count ?? 0) == 0 }
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.servicesProvider = servicesProvider
        self.imageURLProvider = imageURLProvider

        setupObservers()
    }
}

fileprivate extension OWCommentCreationContentViewModel {
    func setupObservers() {
        servicesProvider.authenticationManager()
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

    }
}

