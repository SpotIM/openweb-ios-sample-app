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
    var closeInstantly: PublishSubject<String> { get }
    var ctaTap: PublishSubject<Void> { get }
    var textBeforeClosedChange: BehaviorSubject<String> { get }
    var resetTypeToNewCommentChange: PublishSubject<Void> { get }
    var initialTextUsed: PublishSubject<Void> { get }
    var submitCommentInProgress: BehaviorSubject<Bool> { get }
    var triggerCustomizeSubmitButtonUI: PublishSubject<UIButton> { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModelingOutputs {
    var commentType: OWCommentCreationTypeInternal { get }
    var avatarViewVM: OWAvatarViewModeling { get }
    var textViewVM: OWTextViewViewModeling { get }
    var ctaIcon: UIImage { get }
    var ctaEnabled: Observable<Bool> { get }
    var accessoryViewStrategy: OWAccessoryViewStrategy { get }
    var servicesProvider: OWSharedServicesProviding { get }
    var viewableMode: OWViewableMode { get }
    var performCta: Observable<OWCommentCreationCtaData> { get }
    var closedWithDelay: Observable<Void> { get }
    var closedInstantly: Observable<String> { get }
    var textBeforeClosedChanged: Observable<String> { get }
    var initialText: String { get }
    var resetTypeToNewCommentChanged: Observable<Void> { get }
    var loginToPostClick: Observable<Void> { get }
    var ctaButtonLoading: Observable<Bool> { get }
    var customizeSubmitButtonUI: Observable<UIButton> { get }
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
        static let textViewPlaceholderText = OWLocalizationManager.shared.localizedString(key: "WhatDoYouThink")
        static let ctaIconName = "sendCommentIcon"
        static let delayForDismiss: Int = 350 // ms
    }

    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { return self }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { return self }

    var viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var postId = OWManager.manager.postId

    let servicesProvider: OWSharedServicesProviding
    fileprivate var commentCreationData: OWCommentCreationRequiredData

    fileprivate let _triggerCustomizeSubmitButtonUI = BehaviorSubject<UIButton?>(value: nil)
    var triggerCustomizeSubmitButtonUI = PublishSubject<UIButton>()

    var customizeSubmitButtonUI: Observable<UIButton> {
        return _triggerCustomizeSubmitButtonUI
            .unwrap()
            .asObservable()
    }

    var commentType: OWCommentCreationTypeInternal {
        return commentCreationData.commentCreationType
    }

    let accessoryViewStrategy: OWAccessoryViewStrategy

    var _loginToPostClick = PublishSubject<Void>()
    var loginToPostClick: Observable<Void> {
        _loginToPostClick
            .asObservable()
    }

    var closeInstantly = PublishSubject<String>()
    var closedInstantly: Observable<String> {
        return closeInstantly
            .asObservable()
    }
    var ctaTap = PublishSubject<Void>()
    var closeWithDelay = PublishSubject<Void>()
    var closedWithDelay: Observable<Void> {
        return closeWithDelay
            .asObservable()
    }

    var submitCommentInProgress = BehaviorSubject<Bool>(value: false)
    var ctaButtonLoading: Observable<Bool> {
        submitCommentInProgress
            .asObservable()
    }

    var initialTextUsed = PublishSubject<Void>()

    var resetTypeToNewCommentChange = PublishSubject<Void>()
    var resetTypeToNewCommentChanged: Observable<Void> {
        return resetTypeToNewCommentChange
            .asObservable()
    }

    var textBeforeClosedChange = BehaviorSubject<String>(value: "")
    var textBeforeClosedChanged: Observable<String> {
        return textBeforeClosedChange
            .asObservable()
    }

    var imageURLProvider: OWImageProviding
    var sharedServiceProvider: OWSharedServicesProviding

    lazy var avatarViewVM: OWAvatarViewModeling = {
        return OWAvatarViewModel(imageURLProvider: imageURLProvider)
    }()

    lazy var ctaIcon: UIImage = {
        return UIImage(spNamed: Metrics.ctaIconName)!
    }()

    let textViewVM: OWTextViewViewModeling

    var performCta: Observable<OWCommentCreationCtaData> {
        ctaTap
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: .commenting)
            }
            .do(onNext: { [weak self] loginToPost in
                guard let self = self,
                      loginToPost == true else { return }
                self._loginToPostClick.onNext()
            })
            .filter { !$0 } // Do not continue if authentication needed 
            .withLatestFrom(textViewVM.outputs.textViewText)
            .map { text -> OWCommentCreationCtaData in ()
                let commentContent = OWCommentCreationContent(text: text)
                return OWCommentCreationCtaData(commentContent: commentContent, commentLabelIds: [])
            }
    }

    lazy var resetTypeToNewCommentChangedWithText = resetTypeToNewCommentChanged
        .withLatestFrom(textViewVM.outputs.textViewText)
        .asObservable()

    var ctaEnabled: Observable<Bool> {
        Observable.merge(textViewVM.outputs.textViewText, resetTypeToNewCommentChangedWithText)
            .map { text -> Bool in
                if case .edit(comment: let comment) = self.commentType,
                   let commentText = comment.text?.text,
                   commentText == text {
                    return false
                }

                let adjustedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return !adjustedText.isEmpty
            }
    }

    var initialText = ""

    init(commentCreationData: inout OWCommentCreationRequiredData,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewableMode: OWViewableMode,
         imageURLProvider: OWImageProviding = OWCloudinaryImageProvider(),
         sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.commentCreationData = commentCreationData
        self.servicesProvider = servicesProvider
        self.viewableMode = viewableMode
        self.imageURLProvider = imageURLProvider
        self.sharedServiceProvider = sharedServiceProvider
        let textViewData = OWTextViewData(placeholderText: Metrics.textViewPlaceholderText,
                                          charectersLimitEnabled: false,
                                          isEditable: true,
                                          isAutoExpandable: true,
                                          hasSuggestionsBar: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)

        // Setting accessoryViewStrategy
        let style = commentCreationData.settings.commentCreationSettings.style
        if case let OWCommentCreationStyle.floatingKeyboard(strategy) = style {
            accessoryViewStrategy = strategy
        } else {
            accessoryViewStrategy = OWAccessoryViewStrategy.default
        }

        setupInitialTextAndTypeFromCacheIfNeeded()

        // updating inout commentCreationData so that CommentCreationViewVM will have the updated type
        // after being changed in setupInitialTextAndTypeFromCacheIfNeeded
        commentCreationData.commentCreationType = self.commentCreationData.commentCreationType

        setupObservers()
    }

    fileprivate func setupInitialTextAndTypeFromCacheIfNeeded() {
        let lastCommentTypeInCacheService = self.servicesProvider.lastCommentTypeInMemoryCacheService()
        guard let postId = self.postId else { return }

        let originalCommentType =  commentCreationData.commentCreationType

        if case .comment = commentCreationData.commentCreationType {
            if let lastCommentType = lastCommentTypeInCacheService.value(forKey: postId) {
                commentCreationData.commentCreationType = lastCommentType.toCommentCreationTypeInternal
            }
        }

        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        switch commentType {
        case .comment:
            guard let text = commentsCacheService[.comment(postId: postId)] else { return }
            initialText = text
        case .replyToComment(originComment: let originComment):
            guard let originCommentId = originComment.id,
                  let text = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]
            else { return }
            initialText = text
        case .edit(comment: let comment):
            if case .edit = originalCommentType,
               let commentText = comment.text?.text {
                initialText = commentText
            } else if let text = commentsCacheService[.edit(postId: postId)] {
                initialText = text
            }
        }
    }

    fileprivate func updateCachedLastCommentType() {
        if let postId = self.postId {
            let lastCommentTypeInCacheService = self.servicesProvider.lastCommentTypeInMemoryCacheService()
            switch commentType {
            case .comment:
                lastCommentTypeInCacheService.insert(.newComment, forKey: postId)
            case .edit(comment: let comment):
                lastCommentTypeInCacheService.insert(.edit(comment: comment), forKey: postId)
            case .replyToComment(originComment: let originComment):
                lastCommentTypeInCacheService.insert(.reply(originComment: originComment), forKey: postId)
            }
        }
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardViewViewModel {
    func setupObservers() {
        servicesProvider
            .authenticationManager()
            .activeUserAvailability
            .map { availability -> SPUser? in
                switch availability {
                case .user(let user):
                    return user
                case .notAvailable:
                    return nil
                }
            }
            .bind(to: avatarViewVM.inputs.userInput)
            .disposed(by: disposeBag)

        let commentCreationRequestsService = servicesProvider.commentCreationRequestsService()

        commentCreationRequestsService.newRequest
            .withLatestFrom(textViewVM.outputs.textViewText) { ($0, $1) }
            .withLatestFrom(textViewVM.outputs.cursorRange) { ($0.0, $0.1, $1) }
            .subscribe(onNext: { [weak self] (request, currentText, currentSelectedRange) in
                guard let self = self else { return }
                switch request {
                case .manipulateUserInputText(let manipulationTextCompletion):
                    let manipulationTextModel = OWManipulateTextModel(text: currentText, cursorRange: currentSelectedRange)
                    let newRequestedText = manipulationTextCompletion(.success(manipulationTextModel))
                    self.textViewVM.inputs.textExternalChange.onNext(newRequestedText)
                }
            })
            .disposed(by: disposeBag)

        closedInstantly
            .withLatestFrom(textBeforeClosedChanged)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    self.commentCreationData.commentCreationType = .comment
                }
                self.updateCachedLastCommentType()
            })
            .disposed(by: disposeBag)

        resetTypeToNewCommentChanged
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.commentCreationData.commentCreationType = .comment
                self.updateCachedLastCommentType()
            })
            .disposed(by: disposeBag)

        initialTextUsed
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.initialText = ""
            })
            .disposed(by: disposeBag)

        // UI customizations
        triggerCustomizeSubmitButtonUI
            .bind(to: _triggerCustomizeSubmitButtonUI)
            .disposed(by: disposeBag)
    }
}
