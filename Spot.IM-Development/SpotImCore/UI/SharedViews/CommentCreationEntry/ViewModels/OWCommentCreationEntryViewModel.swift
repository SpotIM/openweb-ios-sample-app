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
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeContainerViewUI: PublishSubject<UIView> { get }
    var tap: PublishSubject<Void> { get }
}

protocol OWCommentCreationEntryViewModelingOutputs {
    var avatarViewVM: OWAvatarViewModeling { get }
    var tapped: Observable<Void> { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeContainerViewUI: Observable<UIView> { get }
}

protocol OWCommentCreationEntryViewModeling {
    var inputs: OWCommentCreationEntryViewModelingInputs { get }
    var outputs: OWCommentCreationEntryViewModelingOutputs { get }
}

class OWCommentCreationEntryViewModel: OWCommentCreationEntryViewModeling,
                                       OWCommentCreationEntryViewModelingInputs,
                                       OWCommentCreationEntryViewModelingOutputs {

    var inputs: OWCommentCreationEntryViewModelingInputs { return self }
    var outputs: OWCommentCreationEntryViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeContainerViewUI = BehaviorSubject<UIView?>(value: nil)

    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeContainerViewUI = PublishSubject<UIView>()

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeContainerViewUI: Observable<UIView> {
        return _triggerCustomizeContainerViewUI
            .unwrap()
            .asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    var imageURLProvider: OWImageProviding
    var sharedServiceProvider: OWSharedServicesProviding

    init (imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(),
          sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
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
        return OWAvatarViewModel(imageURLProvider: imageURLProvider)
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
    }
}
