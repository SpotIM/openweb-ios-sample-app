//
//  OWCommentCreationFloatingKeyboardViewVM.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWCommentCreationFloatingKeyboardViewViewModelingInputs {
    var pop: PublishSubject<Void> { get }
    var closeWithDelay: PublishSubject<Void> { get }
    var closeInstantly: PublishSubject<String> { get }
    var ctaTap: PublishSubject<Void> { get }
    var textBeforeClosedChange: BehaviorSubject<String> { get }
    var resetTypeToNewCommentChange: PublishSubject<Void> { get }
    var initialTextUsed: PublishSubject<Void> { get }
    var submitCommentInProgress: BehaviorSubject<Bool> { get }
    var triggerCustomizeSubmitButtonUI: PublishSubject<UIButton> { get }
    var commentCreationError: PublishSubject<Void> { get }
    var displayToast: PublishSubject<OWToastNotificationCombinedData?> { get }
    var dismissToast: PublishSubject<Void> { get }
}

protocol OWCommentCreationFloatingKeyboardViewViewModelingOutputs {
    var popped: Observable<OWCommentCreationCtaData> { get }
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
    var closedInstantly: Observable<OWCommentCreationCtaData> { get }
    var textBeforeClosedChanged: Observable<String> { get }
    var initialText: String { get }
    var resetTypeToNewCommentChanged: Observable<Void> { get }
    var loginToPostClick: Observable<Void> { get }
    var ctaButtonLoading: Observable<Bool> { get }
    var customizeSubmitButtonUI: Observable<UIButton> { get }
    var userMentionVM: OWUserMentionViewViewModeling { get }
    var displayToastCalled: Observable<OWToastNotificationCombinedData> { get }
    var hideToast: Observable<Void> { get }
    var dismissedToast: Observable<Void> { get }
    var textBeforeClosedWithMentions: Observable<String> { get }
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
        static let maxLandscapeLines = 1
    }

    var displayToast = PublishSubject<OWToastNotificationCombinedData?>()
    var displayToastCalled: Observable<OWToastNotificationCombinedData> {
        return displayToast
            .unwrap()
            .asObservable()
    }

    var dismissToast = PublishSubject<Void>()
    lazy var dismissedToast: Observable<Void> = {
        return dismissToast
            .asObservable()
    }()

    var hideToast: Observable<Void> {
        return Observable.merge(displayToast.filter { $0 == nil }.voidify(),
                                submitCommentInProgress.filter { $0 }.voidify())
            .asObservable()
    }

    var inputs: OWCommentCreationFloatingKeyboardViewViewModelingInputs { return self }
    var outputs: OWCommentCreationFloatingKeyboardViewViewModelingOutputs { return self }

    var commentCreationError = PublishSubject<Void>()

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
    var closedInstantly: Observable<OWCommentCreationCtaData> {
        return closeInstantly
            .withLatestFrom(userMentionVM.outputs.mentionsData) { ($0, $1) }
            .map { text, mentionsData in
                return OWCommentCreationCtaData(commentContent: OWCommentCreationContent(text: text), commentLabelIds: [], commentUserMentions: mentionsData.mentions)
            }
            .asObservable()
    }

    var pop = PublishSubject<Void>()
    var popped: Observable<OWCommentCreationCtaData> {
        return pop
            .withLatestFrom(closedInstantly)
            .asObservable()
    }

    var ctaTap = PublishSubject<Void>()
    var closeWithDelay = PublishSubject<Void>()
    var closedWithDelay: Observable<Void> {
        return closeWithDelay
            .asObservable()
    }

    // This is used to prevent memory leak when binding textViewVM with userMentionVM
    var cursorRangeChange = PublishSubject<Range<String.Index>>()

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
            .withLatestFrom(userMentionVM.outputs.mentionsData) { ($0, $1) }
            .map { text, mentionsData -> String in
                return OWUserMentionHelper.addUserMentionIds(to: text, mentions: mentionsData.mentions)
            }
            .asObservable()
    }

    var textBeforeClosedWithMentions: Observable<String> {
        return textBeforeClosedChange
            .withLatestFrom(userMentionVM.outputs.mentionsData) { ($0, $1) }
            .map { text, mentionsData -> String in
                return OWUserMentionHelper.addUserMentionDisplayNames(to: text, mentions: mentionsData.mentions)
            }
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
    lazy var userMentionVM: OWUserMentionViewViewModeling = {
        return OWUserMentionViewVM(servicesProvider: servicesProvider)
    }()

    lazy var performCta: Observable<OWCommentCreationCtaData> = {
        return ctaTap
            .map { [weak self] _ -> OWUserAction? in
                guard let self = self else { return nil }
                switch self.commentType {
                case .comment:
                    return .commenting
                case .replyToComment:
                    return .replyingComment
                case .edit:
                    return .editingComment
                }
            }
            .unwrap()
            .flatMap { [weak self] userAction -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().ifNeededTriggerAuthenticationUI(for: userAction)
            }
            .do(onNext: { [weak self] loginToPost in
                guard let self = self,
                      loginToPost == true else { return }
                self._loginToPostClick.onNext()
            })
            .filter { !$0 } // Do not continue if authentication needed 
            .withLatestFrom(textViewVM.outputs.textViewText)
            .withLatestFrom(userMentionVM.outputs.mentionsData) { ($0, $1) }
            .map { text, mentionsData -> OWCommentCreationCtaData in
                let commentContent = OWCommentCreationContent(text: text)
                return OWCommentCreationCtaData(commentContent: commentContent, commentLabelIds: [], commentUserMentions: mentionsData.mentions)
            }
            .asObservable()
            .share()
    }()

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
        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let textViewData = OWTextViewData(placeholderText: Metrics.textViewPlaceholderText,
                                          charectersLimitEnabled: false,
                                          showCharectersLimit: false,
                                          isEditable: true,
                                          isAutoExpandable: true,
                                          hasSuggestionsBar: currentOrientation == .portrait)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        // Setting accessoryViewStrategy
        let style = commentCreationData.settings.commentCreationSettings.style
        if case let OWCommentCreationStyle.floatingKeyboard(strategy) = style {
            accessoryViewStrategy = strategy
        } else {
            accessoryViewStrategy = OWAccessoryViewStrategy.default
        }

        setupInitialTextAndTypeFromCacheIfNeeded()
        OWUserMentionHelper.setupInitialMentionsIfNeeded(userMentionVM: userMentionVM,
                                                         commentCreationType: commentCreationData.commentCreationType,
                                                         servicesProvider: servicesProvider,
                                                         postId: postId)

        // updating inout commentCreationData so that CommentCreationViewVM will have the updated type
        // after being changed in setupInitialTextAndTypeFromCacheIfNeeded
        commentCreationData.commentCreationType = self.commentCreationData.commentCreationType

        setupObservers()
    }

    fileprivate func setupInitialTextAndTypeFromCacheIfNeeded() {
        let lastCommentTypeInCacheService = self.servicesProvider.lastCommentTypeInMemoryCacheService()
        guard let postId = self.postId else { return }

        let originalCommentType = commentCreationData.commentCreationType

        if case .comment = commentCreationData.commentCreationType {
            if let lastCommentType = lastCommentTypeInCacheService.value(forKey: postId) {
                commentCreationData.commentCreationType = lastCommentType.toCommentCreationTypeInternal
            }
        }

        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        switch commentType {
        case .comment:
            guard let commentCreationCache = commentsCacheService[.comment(postId: postId)] else { return }
            initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
        case .replyToComment(originComment: let originComment):
            guard let originCommentId = originComment.id,
                  let commentCreationCache = commentsCacheService[.reply(postId: postId, commentId: originCommentId)]
            else { return }
            initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
        case .edit(comment: let comment):
            if case .edit = originalCommentType,
               let commentText = comment.text?.text {
                initialText = commentText
            } else if let commentId = comment.id,
                      let commentCreationCache = commentsCacheService[.edit(postId: postId, commentId: commentId)] {
                initialText = OWUserMentionHelper.addUserMentionDisplayNames(to: commentCreationCache.commentContent.text, mentions: commentCreationCache.commentUserMentions)
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
    // swiftlint:disable function_body_length
    func setupObservers() {
        OWSharedServicesProvider.shared.orientationService().orientation
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }
                let isPortrait = (currentOrientation == .portrait)
                self.textViewVM.inputs.hasSuggestionsBarChange.onNext(isPortrait)

                // We limit textView lines in landscape orientation
                let maxLines = isPortrait ? OWTextViewViewModel.ExternalMetrics.maxNumberOfLines : Metrics.maxLandscapeLines
                self.textViewVM.inputs.maxLinesChange.onNext(maxLines)
            })
            .disposed(by: disposeBag)

        textViewVM.outputs.replaceData
            .bind(to: userMentionVM.inputs.replaceData)
            .disposed(by: disposeBag)

        textViewVM.outputs.textViewText
            .bind(to: userMentionVM.inputs.textViewText)
            .disposed(by: disposeBag)

        textViewVM.outputs.cursorRange
            .bind(to: cursorRangeChange)
            .disposed(by: disposeBag)

        cursorRangeChange
            .bind(to: userMentionVM.inputs.cursorRange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.textChanged
            .bind(to: textViewVM.inputs.textExternalChange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.cursorRangeChanged
            .bind(to: textViewVM.inputs.cursorRangeExternalChange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.attributedTextChanged
            .bind(to: textViewVM.inputs.attributedTextChange)
            .disposed(by: disposeBag)

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
            .subscribe(onNext: { [weak self] request, currentText, currentSelectedRange in
                guard let self = self else { return }
                switch request {
                case .manipulateUserInputText(let manipulationTextCompletion):
                    let manipulationTextModel = OWManipulateTextModel(text: currentText, cursorRange: currentSelectedRange)
                    let textToAppend = manipulationTextCompletion(.success(manipulationTextModel))
                    var currentSelectedRange = currentSelectedRange
                    if textToAppend.isEmpty {
                        currentSelectedRange = currentText.startIndex..<currentText.endIndex
                    }
                    let textData = OWUserMentionTextData(text: currentText, cursorRange: currentSelectedRange, replacingText: textToAppend)
                    let newRequestedText = currentText.replacingCharacters(in: currentSelectedRange, with: textToAppend)
                    self.userMentionVM.inputs.textData.onNext(textData)
                    self.textViewVM.inputs.textExternalChange.onNext(String(newRequestedText.utf16))
                    if !textToAppend.isEmpty,
                       var nsRange = currentText.nsRange(from: currentSelectedRange) {
                        nsRange.location += textToAppend.utf16.count
                        if let range = Range(nsRange, in: newRequestedText) {
                            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                                self?.textViewVM.inputs.cursorRangeExternalChange.onNext(range)
                            }
                        }
                    }
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
