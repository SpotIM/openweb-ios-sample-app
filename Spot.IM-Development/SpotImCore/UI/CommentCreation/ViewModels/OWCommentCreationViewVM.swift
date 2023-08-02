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
    var commentCreated: Observable<OWComment> { get }
    var commentCreationSubmitted: Observable<Void> { get }
}

protocol OWCommentCreationViewViewModeling {
    var inputs: OWCommentCreationViewViewModelingInputs { get }
    var outputs: OWCommentCreationViewViewModelingOutputs { get }
}

class OWCommentCreationViewViewModel: OWCommentCreationViewViewModeling, OWCommentCreationViewViewModelingInputs, OWCommentCreationViewViewModelingOutputs {
    var inputs: OWCommentCreationViewViewModelingInputs { return self }
    var outputs: OWCommentCreationViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()
    fileprivate let commentCreationData: OWCommentCreationRequiredData
    fileprivate let viewableMode: OWViewableMode

    fileprivate lazy var postId = OWManager.manager.postId

    fileprivate lazy var _commentCreated = PublishSubject<OWComment>()
    var commentCreated: Observable<OWComment> {
        _commentCreated
            .asObservable()
    }

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
            commentTextAfterTapObservable = Observable.never()
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
                    .showAlert(title: OWLocalizationManager.shared.localizedString(key: "Close editor?"), message: "", actions: actions, viewableMode: viewableMode)
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
        return OWCommentCreationFloatingKeyboardViewViewModel(commentCreationData: self.commentCreationData)
    }()

    lazy var commentType: OWCommentCreationTypeInternal = {
        return self.commentCreationData.commentCreationType
    }()

    lazy var commentCreationStyle: OWCommentCreationStyle = {
        return self.commentCreationData.settings.commentCreationSettings.style
    }()

    init (commentCreationData: OWCommentCreationRequiredData,
          servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.commentCreationData = commentCreationData
        self.viewableMode = viewableMode
        setupObservers()
    }

    lazy var commentCreationSubmitted: Observable<Void> = {
        // TODO - add floating view cta hadling
        return Observable.merge(commentCreationRegularViewVm.outputs.performCta, commentCreationLightViewVm.outputs.performCta)
            .map { [weak self] commentCreationData -> OWNetworkParameters? in
                // 1 - get create comment request params
                guard let self = self else { return nil }
                return self.getParametersForCreateCommentRequest(from: commentCreationData)
            }
            .unwrap()
            .flatMapLatest { [weak self] networkParameters -> Observable<Event<OWComment>> in
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
            }
            .map { [weak self] event -> OWComment? in
                // 3 - handle network response
                guard let self = self else { return nil }
                switch event {
                case .next(let comment):
                    return comment
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
            .do(onNext: { [weak self] comment in
                // 5 - comment created
                guard let self = self,
                      let postId = self.postId
                else { return }
                self._commentCreated.onNext(comment)
                self.servicesProvider.commentUpdaterService().update(comments: [comment], postId: postId)
            })
            .voidify()
            .share()
    }()
}

fileprivate extension OWCommentCreationViewViewModel {
    func setupObservers() {

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
        case .replyToComment(let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService[.reply(postId: postId, commentId: originCommentId)] = commentText
        case .edit:
            // We are not caching edit comment text
            return
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
