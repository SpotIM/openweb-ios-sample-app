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
    var closeWithDelay: PublishSubject<Void> { get }
    var closeInstantly: PublishSubject<Void> { get }
    var ctaTap: PublishSubject<Void> { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModelingOutputs {
    var commentType: OWCommentCreationTypeInternal { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var textViewVM: OWTextViewViewModeling { get }
    var ctaIcon: UIImage? { get }
    var accessoryViewStrategy: OWAccessoryViewStrategy { get }
    var servicesProvider: OWSharedServicesProviding { get }
    var viewableMode: OWViewableMode { get }
    var performCtaAction: Observable<Void> { get }
    var closedWithDelay: Observable<Void> { get }
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
        static let ctaIconName = "sendCommentIcon"
    }

    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { return self }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { return self }

    var viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentCreationData = BehaviorSubject<OWCommentCreationRequiredData?>(value: nil)

    let commentType: OWCommentCreationTypeInternal
    let accessoryViewStrategy: OWAccessoryViewStrategy

    var closeInstantly = PublishSubject<Void>()
    var ctaTap = PublishSubject<Void>()
    var closeWithDelay = PublishSubject<Void>()
    var closedWithDelay: Observable<Void> {
        return closeWithDelay
            .asObservable()
    }

    var imageURLProvider: OWImageProviding
    var sharedServiceProvider: OWSharedServicesProviding

    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    lazy var ctaIcon: UIImage? = {
        return UIImage(spNamed: Metrics.ctaIconName)
    }()

    let textViewVM: OWTextViewViewModeling

    var performCtaAction: Observable<Void> {
        ctaTap
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .commenting)
            }
            .filter { !$0 } // Do not continue if needed to authenticate
            .map { _ -> Void in () }
    }

    init(commentCreationData: OWCommentCreationRequiredData,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewableMode: OWViewableMode,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(),
         sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.viewableMode = viewableMode
        self._commentCreationData.onNext(commentCreationData)
        self.imageURLProvider = imageURLProvider
        self.sharedServiceProvider = sharedServiceProvider
        let textViewData = OWTextViewData(placeholderText: Metrics.textViewPlaceholderText,
                                          charectersLimitEnabled: false,
                                          isEditable: true,
                                          isAutoExpandable: true,
                                          hasSuggestionsBar: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
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
                    let cursorRange: Range<String.Index> = currentText.endIndex..<currentText.endIndex
                    let manipulationTextModel = OWManipulateTextModel(text: currentText, cursorRange: cursorRange)
                    let newRequestedText = manipulationTextCompletion(.success(manipulationTextModel))
                    self.textViewVM.inputs.textViewTextChange.onNext(newRequestedText)
                }
            })
            .disposed(by: disposeBag)
    }
}
