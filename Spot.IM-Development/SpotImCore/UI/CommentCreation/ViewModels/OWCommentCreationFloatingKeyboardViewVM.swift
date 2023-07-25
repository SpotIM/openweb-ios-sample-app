//
//  OWCommentCreationFloatingKeyboardViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationFloatingKeyboardViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModelingOutputs {
    var commentType: OWCommentCreationType { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var textViewVM: OWTextViewViewModeling { get }
    var sendCommentIcon: UIImage? { get }
    var accessoryViewStrategy: OWAccessoryViewStrategy { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModeling {
    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { get }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { get }
}

class OWCommentCreationFloatingKeyboardViewViewModel:
    OWCommentCreationFloatingKeyboardViewViewModeling,
    OWCommentCreationFloatingKeyboardViewViewModelingInputs,
    OWCommentCreationFloatingKeyboardViewViewModelingOutputs {

    fileprivate struct Metrics {
        static let textViewPlaceholderText = OWLocalizationManager.shared.localizedString(key: "What do you think?")
        static let sendCommentIcon = "sendCommentIcon"
    }

    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { return self }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentCreationData = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)

    let commentType: OWCommentCreationType
    let accessoryViewStrategy: OWAccessoryViewStrategy

    var closeButtonTap = PublishSubject<Void>()
    var imageURLProvider: OWImageProviding
    var sharedServiceProvider: OWSharedServicesProviding

    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    lazy var sendCommentIcon: UIImage? = {
        return UIImage(spNamed: Metrics.sendCommentIcon)
    }()

    let textViewVM: OWTextViewViewModeling

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent,
          imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(),
          sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self._commentCreationData.onNext(commentCreationData)
        self.imageURLProvider = imageURLProvider
        self.sharedServiceProvider = sharedServiceProvider
        self.textViewVM = OWTextViewViewModel(placeholderText: Metrics.textViewPlaceholderText,
                                              textViewText: "",
                                              charectersLimitEnabled: false,
                                              isEditable: true,
                                              isAutoExpandable: true)
        commentType = commentCreationData.commentCreationType

        // Setting accessoryViewStrategy
        let style = commentCreationData.settings.commentCreationSettings.style
        if case let OWCommentCreationStyle.floatingKeyboard(strategy) = style {
            accessoryViewStrategy = strategy
        } else {
            accessoryViewStrategy = OWAccessoryViewStrategy.default
        }
        setupObservers()
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardViewViewModel {
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

        let commentCreationRequestsService = servicesProvider.commentCreationRequestsService()

        commentCreationRequestsService.newRequest
            .withLatestFrom(textViewVM.outputs.textViewText) { ($0, $1) }
            .subscribe(onNext: { [weak self] tuple in
                guard let self = self else { return }
                let request = tuple.0
                let currentText = tuple.1
                switch request {
                case .manipulateUserInputText(let manipulationTextCompletion):
                    let newRequestedText = manipulationTextCompletion(.success(currentText))
                    self.textViewVM.inputs.textViewTextChange.onNext(newRequestedText)
                }
            })
            .disposed(by: disposeBag)
    }
}
