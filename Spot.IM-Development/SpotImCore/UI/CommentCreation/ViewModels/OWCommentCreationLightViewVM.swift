//
//  OWCommentCreationLightViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommentCreationLightViewViewModelingInputs {
    var closeButtonTap: PublishSubject<Void> { get }
    var becomeFirstResponder: PublishSubject<Void> { get }
    var commentCreationError: PublishSubject<Void> { get }
    var displayToast: PublishSubject<OWToastNotificationCombinedData?> { get }
    var dismissToast: PublishSubject<Void> { get }
}

protocol OWCommentCreationLightViewViewModelingOutputs {
    var commentType: OWCommentCreationTypeInternal { get }
    var shouldShowReplySnippet: Bool { get }
    var titleText: Observable<NSAttributedString> { get }
    var replyToAttributedString: Observable<NSAttributedString> { get }

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
}

protocol OWCommentCreationLightViewViewModeling {
    var inputs: OWCommentCreationLightViewViewModelingInputs { get }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { get }
}

class OWCommentCreationLightViewViewModel: OWCommentCreationLightViewViewModeling, OWCommentCreationLightViewViewModelingInputs, OWCommentCreationLightViewViewModelingOutputs {
    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 15.0
    }

    var inputs: OWCommentCreationLightViewViewModelingInputs { return self }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationData: OWCommentCreationRequiredData

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
                                footerViewModel.outputs.ctaButtonLoading.voidify())
            .asObservable()
    }

    var commentCreationError = PublishSubject<Void>()

    fileprivate lazy var postId = OWManager.manager.postId

    var commentType: OWCommentCreationTypeInternal

    lazy var replySnippetViewModel: OWCommentCreationReplySnippetViewModeling = {
        return OWCommentCreationReplySnippetViewModel(commentCreationType: commentType, shouldShowSeparator: false)
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

    var closeButtonTap = PublishSubject<Void>()

    var becomeFirstResponder = PublishSubject<Void>()
    var becomeFirstResponderCalled: Observable<Void> {
        return becomeFirstResponder
            .asObservable()
    }

    var titleText: Observable<NSAttributedString> {
        let title: String
        switch commentCreationData.commentCreationType {
        case .edit:
            title = OWLocalizationManager.shared.localizedString(key: "EditComment")
        default:
            title = OWLocalizationManager.shared.localizedString(key: "AddComment")
        }

        let attributedString = NSMutableAttributedString(string: title)
        let attrs = [NSAttributedString.Key.font: OWFontBook.shared.font(typography: .titleSmall)]
        attributedString.addAttributes(attrs, range: NSRange(location: 0, length: attributedString.length))

        return Observable.just(attributedString)
    }

    var replyToAttributedString: Observable<NSAttributedString> {
        var replyToComment: OWComment? = nil
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
        else { return .empty() }

        let attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "ReplyingTo"))

        let attrs = [NSAttributedString.Key.font: OWFontBook.shared.font(typography: .bodyContext)]
        let boldUserNameString = NSMutableAttributedString(string: displayName, attributes: attrs)

        attributedString.append(boldUserNameString)

        return Observable.just(attributedString)
    }

    var shouldShowReplySnippet: Bool {
        guard let postId = self.postId else { return false }
        var replyToComment: OWComment? = nil
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

    var performCta: Observable<OWCommentCreationCtaData> {
        footerViewModel.outputs.performCtaAction
            .withLatestFrom(commentCreationContentVM.outputs.commentContent)
            .withLatestFrom(commentLabelsContainerVM.outputs.selectedLabelIds) { ($0, $1) }
            .map { OWCommentCreationCtaData(commentContent: $0, commentLabelIds: $1) }
            .asObservable()
    }

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        commentType = commentCreationData.commentCreationType
        setupObservers()
    }
}

fileprivate extension OWCommentCreationLightViewViewModel {
    func setupObservers() {
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
