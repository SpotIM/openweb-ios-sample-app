//
//  OWCommentCreationRegularViewVM.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationRegularViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
    var becomeFirstResponder: PublishSubject<Void> { get }
    var commentCreationError: PublishSubject<Void> { get }
    var displayToast: PublishSubject<OWToastNotificationCombinedData?> { get }
    var dismissToast: PublishSubject<Void> { get }
}

protocol OWCommentCreationRegularViewViewModelingOutputs {
    var commentType: OWCommentCreationTypeInternal { get }
    var shouldShowReplySnippet: Bool { get }
    var titleAttributedString: Observable<NSAttributedString> { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var replySnippetViewModel: OWCommentCreationReplySnippetViewModeling { get }
    var footerViewModel: OWCommentCreationFooterViewModeling { get }
    var commentCounterViewModel: OWCommentReplyCounterViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var commentCreationContentVM: OWCommentCreationContentViewModeling { get }
    var performCta: Observable<OWCommentCreationCtaData> { get }
    var becomeFirstResponderCalled: Observable<Void> { get }
    var displayToastCalled: Observable<OWToastNotificationCombinedData> { get }
    var hideToast: Observable<Void> { get }
    var dismissedToast: Observable<Void> { get }
    var userMentionVM: OWUserMentionViewViewModeling { get }
}

protocol OWCommentCreationRegularViewViewModeling {
    var inputs: OWCommentCreationRegularViewViewModelingInputs { get }
    var outputs: OWCommentCreationRegularViewViewModelingOutputs { get }
}

class OWCommentCreationRegularViewViewModel: OWCommentCreationRegularViewViewModeling, OWCommentCreationRegularViewViewModelingInputs, OWCommentCreationRegularViewViewModelingOutputs {
    var inputs: OWCommentCreationRegularViewViewModelingInputs { return self }
    var outputs: OWCommentCreationRegularViewViewModelingOutputs { return self }

    private let disposeBag = DisposeBag()
    private let servicesProvider: OWSharedServicesProviding
    private let commentCreationData: OWCommentCreationRequiredData

    lazy var userMentionVM: OWUserMentionViewViewModeling = {
        return OWUserMentionViewVM(servicesProvider: servicesProvider)
    }()

    // This is used to prevent memory leak when binding textViewVM with userMentionVM
    var cursorRangeChange = PublishSubject<Range<String.Index>>()

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
                                footerViewModel.outputs.ctaButtonLoading.filter { $0 }.voidify())
            .asObservable()
    }

    var commentCreationError = PublishSubject<Void>()

    private lazy var postId = OWManager.manager.postId

    var commentType: OWCommentCreationTypeInternal

    var closeButtonTap = PublishSubject<Void>()

    var becomeFirstResponder = PublishSubject<Void>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponder
            .asObservable()
    }

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel()
    }()

    lazy var replySnippetViewModel: OWCommentCreationReplySnippetViewModeling = {
        return OWCommentCreationReplySnippetViewModel(commentCreationType: commentType)
    }()

    lazy var footerViewModel: OWCommentCreationFooterViewModeling = {
        return OWCommentCreationFooterViewModel(commentCreationType: commentCreationData.commentCreationType)
    }()

    lazy var commentCounterViewModel: OWCommentReplyCounterViewModeling = {
        return OWCommentReplyCounterViewModel()
    }()

    lazy var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling = {
        return OWCommentLabelsContainerViewModel(commentCreationType: commentCreationData.commentCreationType,
                                                 section: commentCreationData.article.additionalSettings.section)
    }()

    lazy var commentCreationContentVM: OWCommentCreationContentViewModeling = {
        return OWCommentCreationContentViewModel(commentCreationType: commentCreationData.commentCreationType)
    }()

    lazy var titleAttributedString: Observable<NSAttributedString> = {
        let commentingOnText = OWLocalizationManager.shared.localizedString(key: "CommentingOn")

        var replyToComment: OWComment?
        switch commentCreationData.commentCreationType {
        case .edit(let comment):
            if let postId = self.postId,
               let parentId = comment.parentId,
               let parentComment = servicesProvider.commentsService().get(commentId: parentId, postId: postId) {
                replyToComment = parentComment
            }
        case .replyToComment(let originComment):
            replyToComment = originComment
        default:
            break
        }

        guard let userId = replyToComment?.userId,
              let user = self.servicesProvider.usersService().get(userId: userId),
              let displayName = user.displayName
        else { return Observable.just(NSAttributedString(string: commentingOnText)) }

        var attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "ReplyingTo"))

        let attrs = [NSAttributedString.Key.font: OWFontBook.shared.font(typography: .bodyContext)]
        let boldUserNameString = NSMutableAttributedString(string: displayName, attributes: attrs)

        attributedString.append(boldUserNameString)

        return Observable.just(attributedString)
    }()

    var shouldShowReplySnippet: Bool {
        guard let postId = self.postId else { return false }
        var replyToComment: OWComment?
        switch commentType {
        case .edit(let comment):
            if let parentId = comment.parentId,
               let parentComment = servicesProvider.commentsService().get(commentId: parentId, postId: postId) {
                replyToComment = parentComment
            }
        case .replyToComment(let originComment):
            replyToComment = originComment
        default:
            break
        }

        return replyToComment?.text?.text != nil
    }

    lazy var performCta: Observable<OWCommentCreationCtaData> = {
        footerViewModel.outputs.performCtaAction
            .withLatestFrom(commentCreationContentVM.outputs.commentContent)
            .withLatestFrom(commentLabelsContainerVM.outputs.selectedLabelIds) { ($0, $1) }
            .withLatestFrom(userMentionVM.outputs.mentionsData) { ($0.0, $0.1, $1) }
            .map { commentContent, selectedLabelIds, mentionsData in
                return OWCommentCreationCtaData(commentContent: commentContent,
                                                commentLabelIds: selectedLabelIds,
                                                commentUserMentions: mentionsData.mentions)
            }
            .asObservable()
            .share()
    }()

    init(commentCreationData: OWCommentCreationRequiredData,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        self.commentType = commentCreationData.commentCreationType
        setupObservers()
        OWUserMentionHelper.setupInitialMentionsIfNeeded(userMentionVM: userMentionVM,
                                                         commentCreationType: commentCreationData.commentCreationType,
                                                         servicesProvider: servicesProvider,
                                                         postId: postId)
    }
}

private extension OWCommentCreationRegularViewViewModel {
    func setupObservers() {
        commentCreationContentVM.outputs.textViewVM.outputs.replaceData
            .bind(to: userMentionVM.inputs.replaceData)
            .disposed(by: disposeBag)

        commentCreationContentVM.outputs.textViewVM.outputs.textViewText
            .bind(to: userMentionVM.inputs.textViewText)
            .disposed(by: disposeBag)

        commentCreationContentVM.outputs.textViewVM.outputs.cursorRange
            .bind(to: cursorRangeChange)
            .disposed(by: disposeBag)

        cursorRangeChange
            .bind(to: userMentionVM.inputs.cursorRange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.textChanged
            .bind(to: commentCreationContentVM.outputs.textViewVM.inputs.textExternalChange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.cursorRangeChanged
            .bind(to: commentCreationContentVM.outputs.textViewVM.inputs.cursorRangeExternalChange)
            .disposed(by: disposeBag)

        userMentionVM.outputs.attributedTextChanged
            .bind(to: commentCreationContentVM.outputs.textViewVM.inputs.attributedTextChange)
            .disposed(by: disposeBag)

        commentCreationContentVM.outputs.commentContent
            .map { $0.text.count }
            .unwrap()
            .bind(to: commentCounterViewModel.inputs.commentTextCount)
            .disposed(by: disposeBag)

        Observable.combineLatest(
            commentCreationContentVM.outputs.isValidatedContent,
            commentCreationContentVM.outputs.isInitialContentEdited,
            commentLabelsContainerVM.outputs.isValidSelection,
            commentLabelsContainerVM.outputs.isInitialSelectionChanged
        ) { [weak self] isValidContent, isInitialContentEdited, isValidLabelsSelection, isInitialLabelsSelectionChanged in
            guard let self = self else { return false }
            let isValidComment = isValidContent && isValidLabelsSelection
            switch self.commentCreationData.commentCreationType {
            case .edit:
                return isValidComment && (isInitialContentEdited || isInitialLabelsSelectionChanged)
            default:
                return isValidComment
            }
        }
        .bind(to: footerViewModel.inputs.ctaEnabled)
        .disposed(by: disposeBag)

        becomeFirstResponderCalled
            .bind(to: commentCreationContentVM.inputs.becomeFirstResponder)
            .disposed(by: disposeBag)

        closeButtonTap
            .bind(to: commentCreationContentVM.inputs.resignFirstResponder)
            .disposed(by: disposeBag)
    }
}
