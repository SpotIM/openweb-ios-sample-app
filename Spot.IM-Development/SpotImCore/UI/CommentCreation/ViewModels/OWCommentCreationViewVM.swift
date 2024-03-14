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
    var userJustLoggedIn: Observable<Void> { get }
    var viewableMode: OWViewableMode { get }
    var customizeSubmitButtonUI: Observable<UIButton> { get }
}

protocol OWCommentCreationViewViewModeling {
    var inputs: OWCommentCreationViewViewModelingInputs { get }
    var outputs: OWCommentCreationViewViewModelingOutputs { get }
}

class OWCommentCreationViewViewModel: OWCommentCreationViewViewModeling, OWCommentCreationViewViewModelingInputs, OWCommentCreationViewViewModelingOutputs {
    var inputs: OWCommentCreationViewViewModelingInputs { return self }
    var outputs: OWCommentCreationViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let allowedMediaTypes: [String] = ["public.image"]
    }

    fileprivate let commentCreatorNetworkHelper: OWCommentCreatorNetworkHelperProtocol
    fileprivate let disposeBag = DisposeBag()
    let viewableMode: OWViewableMode
    fileprivate let servicesProvider: OWSharedServicesProviding

    var customizeSubmitButtonUI: Observable<UIButton> {
        return Observable.merge(commentCreationRegularViewVm.outputs.footerViewModel.outputs.customizeSubmitButtonUI,
                                commentCreationLightViewVm.outputs.footerViewModel.outputs.customizeSubmitButtonUI,
                                commentCreationFloatingKeyboardViewVm.outputs.customizeSubmitButtonUI)
        .asObservable()
    }

    // This is the original commentCreationData since
    // the commentCreationData Can be chaged by sub VMs
    fileprivate var originCommentCreationData: OWCommentCreationRequiredData

    fileprivate var commentCreationData: OWCommentCreationRequiredData

    fileprivate var articleUrl: String = ""

    fileprivate lazy var postId: OWPostId = OWManager.manager.postId ?? ""

    fileprivate let _commentCreationSubmitInProgrss = BehaviorSubject<Bool>(value: false)

    fileprivate let _userJustLoggedIn = PublishSubject<Void>()
    var userJustLoggedIn: Observable<Void> {
        return _userJustLoggedIn
            .asObservable()
    }

    fileprivate lazy var _commentText: Observable<String> = {
        switch commentCreationData.settings.commentCreationSettings.style {
        case .regular:
            return commentCreationRegularViewVm.outputs.commentCreationContentVM.outputs.commentTextOutput
        case .light:
            return commentCreationLightViewVm.outputs.commentCreationContentVM.outputs.commentTextOutput
        case .floatingKeyboard:
            return commentCreationFloatingKeyboardViewVm.outputs.textBeforeClosedChanged
        }
    }()

    fileprivate lazy var _commentImage: Observable<OWCommentImage?> = {
        switch commentCreationData.settings.commentCreationSettings.style {
        case .regular:
            return commentCreationRegularViewVm.outputs.commentCreationContentVM.outputs.commentImageOutput
        case .light:
            return commentCreationLightViewVm.outputs.commentCreationContentVM.outputs.commentImageOutput
        case .floatingKeyboard:
            return Observable.just(nil)
        }
    }()

    fileprivate lazy var _commentSelectedLabelIds: Observable<[String]> = {
        switch commentCreationData.settings.commentCreationSettings.style {
        case .regular:
            return commentCreationRegularViewVm.outputs.commentLabelsContainerVM.outputs.selectedLabelIds
        case .light:
            return commentCreationLightViewVm.outputs.commentLabelsContainerVM.outputs.selectedLabelIds
        case .floatingKeyboard:
            return Observable.just([])
        }
    }()

    fileprivate lazy var _commentContent: Observable<(String, OWCommentImage?, [String])> = {
        Observable.combineLatest(_commentText, _commentImage, _commentSelectedLabelIds) { commentText, commentImage, commentSelectedLabelIds in
            return (commentText, commentImage, commentSelectedLabelIds)
        }
    }()

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
            return commentCreationFloatingKeyboardViewVm.outputs.closedInstantly
                .do(onNext: { [weak self] commentData in
                    guard let self = self else { return }
                    let hasText = !commentData.commentContent.text.isEmpty
                    if hasText {
                        self.cacheComment(commentContent: commentData.commentContent, commentLabels: nil, commentUserMentions: commentData.commentUserMentions)
                    } else {
                        self.clearCachedCommentIfNeeded()
                    }
                })
                .voidify()
                // floatingKeyboard style does not need a close confirmation mesage, therfore we return the observable of 'commentCreationFloatingKeyboardViewVm' as written above
        }
        return Observable.combineLatest(commentTextAfterTapObservable,
                                        _commentImage,
                                        _commentSelectedLabelIds)
            .do(onNext: { [weak self] _ in
                self?.sendEvent(for: .commentCreationClosePage)
            })
            .flatMap { [weak self] commentText, commentImage, commentSelectedLabelIds -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
                let hasText = !commentText.isEmpty
                let hasImage = commentImage != nil
                let hasSelectedLabel = commentSelectedLabelIds.count > 0
                guard hasText || hasImage || hasSelectedLabel else {
                    self.clearCachedCommentIfNeeded()
                    return Observable.just(())
                }

                self.cacheComment(commentContent: OWCommentCreationContent(text: commentText, image: commentImage), commentLabels: commentSelectedLabelIds, commentUserMentions: nil)
                self.sendEvent(for: .commentCreationLeavePage)
                return Observable.just(())
            }
            .share()
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
         commentCreatorNetworkHelper: OWCommentCreatorNetworkHelperProtocol = OWCommentCreatorNetworkHelper(),
         viewableMode: OWViewableMode) {
        self.originCommentCreationData = commentCreationData
        self.commentCreatorNetworkHelper = commentCreatorNetworkHelper
        self.commentCreationData = commentCreationData
        self.servicesProvider = servicesProvider
        self.viewableMode = viewableMode
        setupObservers()
    }

    lazy var commentCreationSubmitted: Observable<OWComment> = {
        let commentCreationNetworkObservable = Observable.merge(commentCreationRegularViewVm.outputs.performCta,
                                                                commentCreationLightViewVm.outputs.performCta,
                                                                commentCreationFloatingKeyboardViewVm.outputs.performCta)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                switch self.commentCreationData.commentCreationType {
                case .comment:
                    self.sendEvent(for: .postCommentClicked)
                case .edit(let comment):
                    self.sendEvent(for: .editCommentClicked(commentId: comment.id ?? ""))
                case .replyToComment(let originComment):
                    self.sendEvent(for: .postReplyClicked(replyToCommentId: originComment.id ?? ""))
                }
            })
            .map { [weak self] commentCreationData -> (OWCommentCreationCtaData, OWNetworkParameters)? in
                // 1 - get create comment request params
                guard let self = self else { return nil }
                return (commentCreationData, self.commentCreatorNetworkHelper.getParametersForCreateCommentRequest(
                    from: commentCreationData,
                    section: self.commentCreationData.article.additionalSettings.section,
                    commentCreationType: self.commentCreationData.commentCreationType,
                    postId: self.postId
                ))
            }
            .unwrap()
            .do(onNext: { [weak self] _, _ in
                guard let self = self else { return }
                self._commentCreationSubmitInProgrss.onNext(true)
            })
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
                    // TODO - Handle error
                    self._commentCreationSubmitInProgrss.onNext(false)
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()

        let prepareLocalCommentObservable = commentCreationNetworkObservable
            .do(onNext: { [weak self] _ in
                // 4 - clear cached comment if exists
                guard let self = self else { return }
                let commentCacheService = self.servicesProvider.commentsInMemoryCacheService()
                switch self.commentCreationData.commentCreationType {
                case .comment:
                    commentCacheService.remove(forKey: .comment(postId: self.postId))
                case .replyToComment(originComment: let originComment):
                    guard let originCommentId = originComment.id else { return }
                    commentCacheService.remove(forKey: .reply(postId: self.postId, commentId: originCommentId))
                case .edit:
                    commentCacheService.remove(forKey: .edit(postId: self.postId))
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

        return prepareLocalCommentObservable
            .do(onNext: { [weak self] comment in
                // 6 - comment created
                guard let self = self else { return }
                let commentUpdateType: OWConversationUpdateType?
                switch self.commentCreationData.commentCreationType {
                case .comment:
                    commentUpdateType = .insert(comments: [comment])
                case .edit:
                    guard let commentId = comment.id else { return }
                    var updatedComment = comment
                    updatedComment.setIsEdited(true)
                    commentUpdateType = .update(commentId: commentId, withComment: updatedComment)
                case .replyToComment(originComment: let originComment):
                    guard let commentId = originComment.id else { return }
                    commentUpdateType = .insertReply(comment: comment, toParentCommentId: commentId)                }
                if let updateType = commentUpdateType {
                    self.servicesProvider
                        .conversationUpdaterService()
                        .update(updateType, postId: self.postId)
                }
            })
            .flatMap({ [weak self] comment -> Observable<OWComment> in
                guard let self = self,
                      case .floatingKeyboard = self.commentCreationData.settings.commentCreationSettings.style
                else { return Observable.just(comment) }
                self.commentCreationFloatingKeyboardViewVm.inputs.closeWithDelay.onNext()
                return self.commentCreationFloatingKeyboardViewVm.outputs.closedInstantly
                    .map { _ -> OWComment in
                        return comment
                    }
            })
            .do(onNext: { [weak self] comment in
                guard let self = self else { return }
                self.servicesProvider
                    .commentStatusUpdaterService()
                    .fetchStatusFor(comment: comment)
                self._commentCreationSubmitInProgrss.onNext(false)
            })
            .share()
    }()
}

fileprivate extension OWCommentCreationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        servicesProvider.activeArticleService().updateStrategy(commentCreationData.article.articleInformationStrategy)

        if case .floatingKeyboard = commentCreationData.settings.commentCreationSettings.style {
            commentCreationFloatingKeyboardViewVm.outputs.resetTypeToNewCommentChanged
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.commentCreationData.commentCreationType = .comment
                })
                .disposed(by: disposeBag)
        }

        Observable.merge(
            commentCreationRegularViewVm.outputs.footerViewModel.outputs.loginToPostClick,
            commentCreationLightViewVm.outputs.footerViewModel.outputs.loginToPostClick,
            commentCreationFloatingKeyboardViewVm.outputs.loginToPostClick
        )
        .do(onNext: { [weak self] in
            self?.sendEvent(for: .signUpToPostClicked)
        })
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
        .flatMapLatest { [weak self] userAction -> Observable<Bool> in
            guard let self = self else { return .empty() }
            return self.servicesProvider.authenticationManager().waitForAuthentication(for: userAction)
        }
        .filter { $0 }
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.servicesProvider.conversationUpdaterService().update(.refreshConversation, postId: self.postId)
        })
        .map { [weak self] _ -> OWCommentId? in
            guard let self = self else { return nil }
            if case let .replyToComment(originComment) = self.commentCreationData.commentCreationType {
                return originComment.id
            } else {
                return nil
            }
        }
        .withLatestFrom(_commentContent) { ($0, $1) }
        .do(onNext: { [weak self] replyToCommentId, commentContent in
            guard let self = self else { return }
            if replyToCommentId != nil {
                let commentText = commentContent.0
                let commentImage = commentContent.1
                let commentSelectedLabelIds = commentContent.2

                self.cacheComment(commentContent: OWCommentCreationContent(text: commentText, image: commentImage), commentLabels: commentSelectedLabelIds, commentUserMentions: nil)
            }
        })
        .subscribe(onNext: { [weak self] replyToCommentId, _ in
            guard let self = self else { return }
            self._userJustLoggedIn.onNext()
            if let replyToCommentId = replyToCommentId {
                self.servicesProvider.actionsCallbacksNotifier()
                    .openCommentThread(commentId: replyToCommentId,
                                       performAction: .reply)
            }
        })
        .disposed(by: disposeBag)

        let selectMediaOptionsObservable = Observable.merge(
            commentCreationRegularViewVm.outputs.footerViewModel.outputs.addImageTapped,
            commentCreationLightViewVm.outputs.footerViewModel.outputs.addImageTapped
        )
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.sendEvent(for: .cameraIconClickedOpen)
            })
            .flatMap { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return Observable.just(false) }
                return self.servicesProvider
                    .permissionsService()
                    .requestPermission(for: .camera, viewableMode: self.viewableMode)
            }
            .filter { $0 == true }
            .voidify()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }

                let actions = [
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "TakeAPhoto"), type: OWPickImageActionSheet.takePhoto),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "ChooseFromGallery"), type: OWPickImageActionSheet.chooseFromGallery),
                    OWRxPresenterAction(title: OWLocalizationManager.shared.localizedString(key: "Cancel"), type: OWPickImageActionSheet.cancel, style: .cancel)
                ]
                return self.servicesProvider
                    .presenterService()
                    .showAlert(
                        title: nil,
                        message: nil,
                        actions: actions,
                        preferredStyle: .actionSheet,
                        viewableMode: self.viewableMode
                    )
            }

        let userSelectedMediaObservable = selectMediaOptionsObservable
            .map { [weak self] response -> UIImagePickerController.SourceType? in
                guard let self = self else { return nil }
                switch response {
                case .completion:
                    return nil
                case .selected(let action):
                    switch action.type {
                    case OWPickImageActionSheet.takePhoto:
                        self.sendEvent(for: .cameraIconClickedTakePhoto)
                        return .camera
                    case OWPickImageActionSheet.chooseFromGallery:
                        self.sendEvent(for: .cameraIconClickedChooseFromGallery)
                        return .photoLibrary
                    case OWPickImageActionSheet.cancel:
                        self.sendEvent(for: .cameraIconClickedClose)
                        return nil
                    default:
                        return nil
                    }
                }
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] sourceType -> Observable<OWImagePickerPresenterResponseType> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .presenterService()
                    .showImagePicker(mediaTypes: Metrics.allowedMediaTypes, sourceType: sourceType, viewableMode: self.viewableMode)
            }
            .map { response -> UIImage? in
                switch response {
                case .cancled:
                    return nil
                case .mediaInfo(let dictionary):
                    guard let image = dictionary[.originalImage] as? UIImage else {
                        return nil
                    }
                    return image
                }
            }
            .unwrap()

        userSelectedMediaObservable
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                switch self.commentCreationData.settings.commentCreationSettings.style {
                case .regular:
                    self.commentCreationRegularViewVm.outputs.commentCreationContentVM.inputs.imagePicked.onNext(image)
                case .light:
                    self.commentCreationLightViewVm.outputs.commentCreationContentVM.inputs.imagePicked.onNext(image)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        servicesProvider
            .activeArticleService()
            .articleExtraData
            .subscribe(onNext: { [weak self] article in
                self?.articleUrl = article.url.absoluteString
            })
            .disposed(by: disposeBag)

        self._commentCreationSubmitInProgrss
            .subscribe(onNext: { [weak self] isInProgress in
                guard let self = self else { return }
                self.commentCreationRegularViewVm.outputs.footerViewModel.inputs.submitCommentInProgress.onNext(isInProgress)
                self.commentCreationLightViewVm.outputs.footerViewModel.inputs.submitCommentInProgress.onNext(isInProgress)
                self.commentCreationFloatingKeyboardViewVm.inputs.submitCommentInProgress.onNext(isInProgress)
            })
            .disposed(by: disposeBag)
    }

    func cacheComment(commentContent: OWCommentCreationContent, commentLabels: [String]?, commentUserMentions: [OWUserMentionObject]?) {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()

        let commentLabels = commentLabels ?? [String]()
        let commentData = OWCommentCreationCtaData(commentContent: commentContent, commentLabelIds: commentLabels, commentUserMentions: commentUserMentions)

        switch commentCreationData.commentCreationType {
        case .comment:
            commentsCacheService[.comment(postId: self.postId)] = commentData
            commentsCacheService.remove(forKey: .edit(postId: self.postId))
        case .replyToComment(let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService[.reply(postId: self.postId, commentId: originCommentId)] = commentData
        case .edit:
            commentsCacheService[.edit(postId: self.postId)] = commentData
        }
    }

    func clearCachedCommentIfNeeded() {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()
        switch commentCreationData.commentCreationType {
        case .comment:
            commentsCacheService.remove(forKey: .comment(postId: self.postId))
        case .replyToComment(originComment: let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService.remove(forKey: .reply(postId: self.postId, commentId: originCommentId))
        case .edit:
            break
        }
    }

    func event(for eventType: OWAnalyticEventType) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: articleUrl,
                layoutStyle: OWLayoutStyle(from: commentCreationData.presentationalStyle),
                component: .commentCreation)
    }

    func sendEvent(for eventType: OWAnalyticEventType) {
        let event = event(for: eventType)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }
}
