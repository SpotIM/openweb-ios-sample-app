//
//  OWCommentCreationViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationViewViewModelingInputs {

}

protocol OWCommentCreationViewViewModelingOutputs {
    var commentCreationRegularViewVm: OWCommentCreationRegularViewViewModeling { get }
    var commentCreationLightViewVm: OWCommentCreationLightViewViewModeling { get }
    var commentCreationFloatingKeyboardViewVm: OWCommentCreationFloatingKeyboardViewViewModeling { get }
    var commentType: OWCommentCreationTypeInternal { get }
    var commentCreationStyle: OWCommentCreationStyle { get }
    var closeButtonTapped: Observable<Void> { get }
    var commentCreationSubmitted: Observable<OWComment> { get }
}

protocol OWCommentCreationViewViewModeling {
    var inputs: OWCommentCreationViewViewModelingInputs { get }
    var outputs: OWCommentCreationViewViewModelingOutputs { get }
}

class OWCommentCreationViewViewModel: OWCommentCreationViewViewModeling, OWCommentCreationViewViewModelingInputs, OWCommentCreationViewViewModelingOutputs {
    var inputs: OWCommentCreationViewViewModelingInputs { return self }
    var outputs: OWCommentCreationViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewableMode: OWViewableMode
    fileprivate let servicesProvider: OWSharedServicesProviding

    // This is the original commentCreationData since
    // the commentCreationData Can be chaged by sub VMs
    fileprivate var originCommentCreationData: OWCommentCreationRequiredData

    fileprivate var commentCreationData: OWCommentCreationRequiredData

    fileprivate lazy var postId = OWManager.manager.postId

    lazy var closeButtonTapped: Observable<Void> = {
        let commentTextAfterTapObservable: Observable<String>
        switch commentCreationData.settings.commentCreationSettings.style {
        case .regular:
            commentTextAfterTapObservable = commentCreationRegularViewVm.inputs.closeButtonTap
                .withLatestFrom(commentCreationRegularViewVm.outputs.commentCreationContentVM.outputs.commentTextOutput)
        case .light:
            commentTextAfterTapObservable = commentCreationLightViewVm.inputs.closeButtonTap
                .withLatestFrom(commentCreationLightViewVm.outputs.commentCreationContentVM.outputs.commentTextOutput)
        case .floatingKeyboard:
            return commentCreationFloatingKeyboardViewVm.inputs.closeInstantly
                .flatMap { [weak self] commentText -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    let hasText = !commentText.isEmpty
                    guard hasText else {
                        self.clearCachedCommentIfNeeded()
                        return Observable.just(())
                    }
                    self.cacheComment(text: commentText)
                    return Observable.just(())
                }
        }
        return commentTextAfterTapObservable
            .flatMap { [weak self] commentText -> Observable<Void> in
                guard let self = self else { return .empty() }
                let hasText = !commentText.isEmpty
                guard hasText else {
                    self.clearCachedCommentIfNeeded()
                    return Observable.just(())
                }
                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Yes"), type: OWCloseEditorAlert.yes),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "No"), type: OWCloseEditorAlert.no, style: .cancel)
                ]
                return self.servicesProvider.presenterService()
                    // TODO - Localization
                    .showAlert(title: OWLocalizationManager.shared.localizedString(key: "Close editor?"), message: "", actions: actions, viewableMode: self.viewableMode)
                    .flatMap { result -> Observable<Void> in
                        switch result {
                        case .completion:
                            return Observable.empty()
                        case .selected(let action):
                            switch action.type {
                            case OWCloseEditorAlert.yes:
                                self.cacheComment(text: commentText)
                                return Observable.just(())
                            default:
                                return Observable.empty()
                            }
                        }
                    }
            }
    }()

    lazy var commentCreationRegularViewVm: OWCommentCreationRegularViewViewModeling = {
        return OWCommentCreationRegularViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentCreationLightViewVm: OWCommentCreationLightViewViewModeling = {
        return OWCommentCreationLightViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentCreationFloatingKeyboardViewVm: OWCommentCreationFloatingKeyboardViewViewModeling = {
        return OWCommentCreationFloatingKeyboardViewViewModel(commentCreationData: &self.commentCreationData, viewableMode: viewableMode)
    }()

    lazy var commentType: OWCommentCreationTypeInternal = {
        return self.commentCreationData.commentCreationType
    }()

    lazy var commentCreationStyle: OWCommentCreationStyle = {
        return self.commentCreationData.settings.commentCreationSettings.style
    }()

    init(commentCreationData: OWCommentCreationRequiredData,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         viewableMode: OWViewableMode) {
        self.originCommentCreationData = commentCreationData
        self.commentCreationData = commentCreationData
        self.servicesProvider = servicesProvider
        self.viewableMode = viewableMode
        setupObservers()
    }

    lazy var commentCreationSubmitted: Observable<OWComment> = {
        // TODO - add floating view cta hadling
        return Observable.merge(commentCreationRegularViewVm.outputs.performCta, commentCreationLightViewVm.outputs.performCta)
            .map { [weak self] commentCreationData -> (OWCommentCreationCtaData, OWNetworkParameters)? in
                // 1 - get create comment request params
                guard let self = self else { return nil }
                return (commentCreationData, self.getParametersForCreateCommentRequest(from: commentCreationData))
            }
            .unwrap()
            .flatMapLatest { [weak self] commentCreationData, networkParameters -> Observable<(OWCommentCreationCtaData, Event<OWComment>)> in
                // 2 - perform create comment request
                guard let self = self else { return .empty() }

                let conversationApi = self.servicesProvider.netwokAPI().conversation

                let commentNetworkResponse: OWNetworkResponse<OWComment>
                switch self.commentCreationData.commentCreationType {
                case .comment, .replyToComment:
                    commentNetworkResponse = conversationApi.commentPost(parameters: networkParameters)
                case .edit:
                    commentNetworkResponse = conversationApi.commentUpdate(parameters: networkParameters)
                }

                return commentNetworkResponse
                    .response
                    .materialize()
                    .map { (commentCreationData, $0) }
            }
            .map { [weak self] (commentCreationData, event) -> (OWCommentCreationCtaData, OWComment)? in
                // 3 - handle network response
                guard let self = self else { return nil }
                switch event {
                case .next(let comment):
                    return (commentCreationData, comment)
                case .error(_):
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .do(onNext: { [weak self] _ in
                // 4 - clear cached comment if exists
                guard let self = self,
                      let postId = self.postId
                else { return }
                let commentCacheService = self.servicesProvider.commentsInMemoryCacheService()
                switch self.commentCreationData.commentCreationType {
                case .comment:
                    commentCacheService.remove(forKey: .comment(postId: postId))
                case .replyToComment(originComment: let originComment):
                    guard let originCommentId = originComment.id else { return }
                    commentCacheService.remove(forKey: .reply(postId: postId, commentId: originCommentId))
                case .edit:
                    break
                }
            })
            .withLatestFrom(self.servicesProvider.authenticationManager().activeUserAvailability) { ($0.0, $0.1, $1) }
            .map { [weak self] commentCreationData, comment, userAvailability -> OWComment? in
                // 5 - populate local comment data
                guard let self = self,
                      case let .user(user) = userAvailability
                else { return nil }

                var additionalData = OWComment.AdditionalData()
                if !commentCreationData.commentLabelIds.isEmpty {
                    additionalData.labels = OWComment.CommentLabel(
                        section: self.commentCreationData.article.additionalSettings.section,
                        ids: commentCreationData.commentLabelIds
                    )
                }

                return self.servicesProvider.localCommentDataPopulator()
                    .populate(
                        commentResponse: comment,
                        with: additionalData,
                        user: user,
                        commentCreationType: self.commentCreationData.commentCreationType
                    )
            }
            .unwrap()
            .do(onNext: { [weak self] comment in
                // 6 - comment created
                guard let self = self,
                      let postId = self.postId
                else { return }
                let commentUpdateType: OWCommentUpdateType?
                switch self.commentCreationData.commentCreationType {
                case .comment:
                    commentUpdateType = .insert(comments: [comment])
                case .edit:
                    guard let commentId = comment.id else { return }
                    commentUpdateType = .update(commentId: commentId, withComment: comment)
                case .replyToComment(originComment: let originComment):
                    guard let commentId = originComment.id else { return }
                    commentUpdateType = .reply(comment: comment, toCommentId: commentId)                }
                if let updateType = commentUpdateType {
                    self.servicesProvider
                        .commentUpdaterService()
                        .update(updateType, postId: postId)
                }
            })
            .share()
    }()
}

fileprivate extension OWCommentCreationViewViewModel {
    func setupObservers() {
        if case .floatingKeyboard = commentCreationData.settings.commentCreationSettings.style {
            commentCreationFloatingKeyboardViewVm.outputs.resetTypeToNewCommentChanged
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.commentCreationData.commentCreationType = .comment
                })
                .disposed(by: disposeBag)
        }
    }

    func getParametersForCreateCommentRequest(from commentCreationData: OWCommentCreationCtaData) -> OWNetworkParameters {
        var metadata: [String: Any] = [:]

        if let bundleId = Bundle.main.bundleIdentifier {
            metadata["app_bundle_id"] = bundleId
        }

        var parameters: [String: Any] = [
            "content": self.getContentRequestParam(from: commentCreationData)
        ]

        if !commentCreationData.commentLabelIds.isEmpty {
            parameters["additional_data"] = [
                "labels": [
                    "section": self.commentCreationData.article.additionalSettings.section,
                    "ids": commentCreationData.commentLabelIds
                ] as [String: Any]
            ]
        }

        switch self.commentCreationData.commentCreationType {
        case .comment:
            break
        case .edit(let comment):
            if let messageId = comment.id {
                parameters["message_id"] = messageId
            }
        case .replyToComment(let originComment):
            let commentId = originComment.id
            let rootCommentId = originComment.rootComment
            let isRootComment = commentId == rootCommentId
            if !isRootComment {
                metadata["reply_to"] = ["reply_id": commentId]
            }
            parameters["conversation_id"] = postId
            parameters["parent_id"] = rootCommentId ?? commentId
        }

        parameters["metadata"] = metadata

        return parameters
    }

    func getContentRequestParam(from commentCreationData: OWCommentCreationCtaData) -> [[String: Any]] {
        var content: [[String: Any]] = []

        if !commentCreationData.text.isEmpty {
            content.append([
                "type": "text",
                "text": commentCreationData.text
            ])
        }

        return content
    }

    func cacheComment(text commentText: String) {
        guard let postId = self.postId else { return }
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()

        switch commentCreationData.commentCreationType {
        case .comment:
            commentsCacheService[.comment(postId: postId)] = commentText
            commentsCacheService[.edit(postId: postId)] = nil
        case .replyToComment(let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService[.reply(postId: postId, commentId: originCommentId)] = commentText
        case .edit:
            commentsCacheService[.edit(postId: postId)] = commentText
        }
    }

    func clearCachedCommentIfNeeded() {
        guard let postId = self.postId else { return }
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        switch commentCreationData.commentCreationType {
        case .comment:
            commentsCacheService.remove(forKey: .comment(postId: postId))
        case .replyToComment(originComment: let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService.remove(forKey: .reply(postId: postId, commentId: originCommentId))
        case .edit:
            break
        }
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: commentCreationData.article.url.absoluteString,
                layoutStyle: OWLayoutStyle(from: commentCreationData.presentationalStyle),
                component: .commentCreation)
    }
}
