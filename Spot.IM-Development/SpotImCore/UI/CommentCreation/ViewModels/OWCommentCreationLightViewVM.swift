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
    var commentType: OWCommentCreationType { get }
    var shouldShowReplySnippet: Bool { get }
    var titleText: Observable<String> { get }
    var replyToAttributedString: Observable<NSAttributedString> { get }

    var replySnippetViewModel: OWCommentCreationReplySnippetViewModeling { get }
    var footerViewModel: OWCommentCreationFooterViewModeling { get }
    var commentCounterViewModel: OWCommentReplyCounterViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var commentCreationContentVM: OWCommentCreationContentViewModeling { get }
}

protocol OWCommentCreationLightViewViewModeling {
    var inputs: OWCommentCreationLightViewViewModelingInputs { get }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { get }
}

class OWCommentCreationLightViewViewModel: OWCommentCreationLightViewViewModeling, OWCommentCreationLightViewViewModelingInputs, OWCommentCreationLightViewViewModelingOutputs {
    var inputs: OWCommentCreationLightViewViewModelingInputs { return self }
    var outputs: OWCommentCreationLightViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let commentCreationData: OWCommentCreationRequiredData

    var commentType: OWCommentCreationType

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
            if let postId = OWManager.manager.postId,
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

        var attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "Replying to "))

        let attrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        let boldUserNameString = NSMutableAttributedString(string: displayName, attributes: attrs)

        attributedString.append(boldUserNameString)

        return Observable.just(attributedString)
    }

    var shouldShowReplySnippet: Bool {
        guard let postId = OWManager.manager.postId else { return false }
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

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode = .independent) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        commentType = commentCreationData.commentCreationType
        setupObservers()
    }
}

fileprivate extension OWCommentCreationLightViewViewModel {
    func setupObservers() {
        commentCreationContentVM.outputs.commentTextOutput
            .map { $0.count }
            .unwrap()
            .bind(to: commentCounterViewModel.inputs.commentTextCount)
            .disposed(by: disposeBag)

        commentCreationContentVM.outputs.commentTextOutput
            .map { !$0.isEmpty }
            .bind(to: footerViewModel.inputs.ctaEnabled)
            .disposed(by: disposeBag)

        footerViewModel.outputs.performCtaAction
            .subscribe(onNext: { _ in
                // TODO - handle post / edit comment
            })
            .disposed(by: disposeBag)
    }
}
