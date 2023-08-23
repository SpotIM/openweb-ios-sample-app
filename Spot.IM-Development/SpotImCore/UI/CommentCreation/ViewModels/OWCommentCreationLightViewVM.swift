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
}

protocol OWCommentCreationLightViewViewModelingOutputs {
    var commentType: OWCommentCreationTypeInternal { get }
    var shouldShowReplySnippet: Bool { get }
    var titleText: Observable<String> { get }
    var replyToAttributedString: Observable<NSAttributedString> { get }

    var replySnippetViewModel: OWCommentCreationReplySnippetViewModeling { get }
    var footerViewModel: OWCommentCreationFooterViewModeling { get }
    var commentCounterViewModel: OWCommentReplyCounterViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var commentCreationContentVM: OWCommentCreationContentViewModeling { get }
    var performCta: Observable<OWCommentCreationCtaData> { get }
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
    fileprivate let viewableMode: OWViewableMode
    fileprivate let commentCreationData: OWCommentCreationRequiredData

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
        return OWCommentLabelsContainerViewModel(section: commentCreationData.article.additionalSettings.section)
    }()

    lazy var commentCreationContentVM: OWCommentCreationContentViewModeling = {
        return OWCommentCreationContentViewModel(commentCreationType: commentCreationData.commentCreationType)
    }()

    var closeButtonTap = PublishSubject<Void>()

    var titleText: Observable<String> {
        switch commentCreationData.commentCreationType {
        case .edit:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "Edit a comment"))
        default:
            return Observable.just(OWLocalizationManager.shared.localizedString(key: "Add a comment"))
        }
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

        let attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "Replying to "))

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
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        self.viewableMode = viewableMode
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

        commentCreationContentVM.outputs.commentContent
            .map { $0.hasContent() }
            .bind(to: footerViewModel.inputs.ctaEnabled)
            .disposed(by: disposeBag)
    }
}
