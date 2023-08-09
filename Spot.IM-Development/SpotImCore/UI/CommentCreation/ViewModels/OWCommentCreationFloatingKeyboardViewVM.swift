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
    var textBeforeClosedChanged: PublishSubject<String> { get }
    var resetTypeToNewCommentChange: PublishSubject<Void> { get }
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
    var textBeforeClosed: Observable<String> { get }
    var initialText: String { get }
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

    fileprivate lazy var postId = OWManager.manager.postId

    let servicesProvider: OWSharedServicesProviding
    fileprivate var commentCreationData: OWCommentCreationRequiredData

    var commentType: OWCommentCreationTypeInternal = .comment
    let accessoryViewStrategy: OWAccessoryViewStrategy

    var closeInstantly = PublishSubject<String>()
    var ctaTap = PublishSubject<Void>()
    var closeWithDelay = PublishSubject<Void>()
    var closedWithDelay: Observable<Void> {
        return closeWithDelay
            .asObservable()
    }

    var resetTypeToNewCommentChange = PublishSubject<Void>()
    var resetTypeToNewComment: Observable<Void> {
        return resetTypeToNewCommentChange
            .asObservable()
    }

    var textBeforeClosedChanged = PublishSubject<String>()
    var textBeforeClosed: Observable<String> {
        return textBeforeClosedChanged
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
        setupObservers()

        self.setupInitialTextAndTypeIfNeeded()
    }

    fileprivate func setupInitialTextAndTypeIfNeeded() {
        let lastCommentTypeInCacheService = self.servicesProvider.lastCommentTypeInMemoryCacheService()
        guard let postId = self.postId else { return }

        if case .comment = commentCreationData.commentCreationType {
            if let lastCommentType = lastCommentTypeInCacheService.value(forKey: postId) {
                commentCreationData.commentCreationType = lastCommentType.toCommentCreationTypeInternal
            }
        }

        commentType = commentCreationData.commentCreationType

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
            if let commentText = comment.text?.text {
                initialText = commentText
            }
        }
    }

    fileprivate func updateCachedLastCommentType() {
        if let postId = self.postId {
            let lastCommentTypeInCacheService = self.servicesProvider.lastCommentTypeInMemoryCacheService()
            switch commentType {
            case .comment:
                lastCommentTypeInCacheService.insert(.comment, forKey: postId)
            case .edit(comment: let comment):
                lastCommentTypeInCacheService.insert(.edit(comment: comment), forKey: postId)
            case .replyToComment(originComment: let originComment):
                lastCommentTypeInCacheService.insert(.reply(comment: originComment), forKey: postId)
            }
        }
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

        closeInstantly
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateCachedLastCommentType()
            })
            .disposed(by: disposeBag)

        resetTypeToNewComment
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.commentType = .comment
                self.commentCreationData.commentCreationType = .comment
                self.updateCachedLastCommentType()
            })
            .disposed(by: disposeBag)
    }
}
