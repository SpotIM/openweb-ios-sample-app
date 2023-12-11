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
    var commentCreationSubmitted: Observable<(OWComment, Bool)> { get }
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

    fileprivate var _userLoggedIn: Bool = false

    fileprivate let _commentCreationSubmitInProgrss = BehaviorSubject<Bool>(value: false)

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
                .do(onNext: { [weak self] commentText in
                    guard let self = self else { return }
                    let hasText = !commentText.isEmpty
                    if hasText {
                        self.cacheComment(text: commentText)
                    } else {
                        self.clearCachedCommentIfNeeded()
                    }
                })
                .voidify()
                // floatingKeyboard style does not need a close confirmation mesage, therfore we return the observable of 'commentCreationFloatingKeyboardViewVm' as written above
        }
        return commentTextAfterTapObservable
            .do(onNext: { [weak self] _ in
                self?.sendEvent(for: .commentCreationClosePage)
            })
            .flatMap { [weak self] commentText -> Observable<Void> in
                guard let self = self else { return Observable.empty() }
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
                    .showAlert(title: OWLocalizationManager.shared.localizedString(key: "CloseEditor"), message: "", actions: actions, viewableMode: self.viewableMode)
                    .flatMap { [weak self] result -> Observable<Void> in
                        guard let self = self else { return .empty() }
                        switch result {
                        case .completion:
                            return Observable.empty()
                        case .selected(let action):
                            switch action.type {
                            case OWCloseEditorAlert.yes:
                                self.cacheComment(text: commentText)
                                self.sendEvent(for: .commentCreationLeavePage)
                                return Observable.just(())
                            default:
                                self.commentCreationRegularViewVm.inputs.becomeFirstResponder.onNext()
                                self.commentCreationLightViewVm.inputs.becomeFirstResponder.onNext()
                                self.sendEvent(for: .commentCreationContinueWriting)
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
         commentCreatorNetworkHelper: OWCommentCreatorNetworkHelperProtocol = OWCommentCreatorNetworkHelper(),
         viewableMode: OWViewableMode) {
        self.originCommentCreationData = commentCreationData
        self.commentCreatorNetworkHelper = commentCreatorNetworkHelper
        self.commentCreationData = commentCreationData
        self.servicesProvider = servicesProvider
        self.viewableMode = viewableMode
        setupObservers()
    }

    lazy var commentCreationSubmitted: Observable<(OWComment, Bool)> = {
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
            .map { ($0, self._userLoggedIn) }
            .do(onNext: { [weak self] comment, userJustLoggedIn in
                guard let self = self,
                      userJustLoggedIn,
                      let commentId = comment.id
                else { return }
                self.servicesProvider
                    .actionsCallbacksNotifier()
                    .openCommentThread(commentId: commentId,
                                       performAction: .reply)
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
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self._userLoggedIn = true
            self.servicesProvider.conversationUpdaterService().update(.refreshConversation, postId: self.postId)
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

    func cacheComment(text commentText: String) {
        let commentsCacheService = self.servicesProvider.commentsInMemoryCacheService()

        switch commentCreationData.commentCreationType {
        case .comment:
            commentsCacheService[.comment(postId: self.postId)] = commentText
            commentsCacheService.remove(forKey: .edit(postId: self.postId))
        case .replyToComment(let originComment):
            guard let originCommentId = originComment.id else { return }
            commentsCacheService[.reply(postId: self.postId, commentId: originCommentId)] = commentText
        case .edit:
            commentsCacheService[.edit(postId: self.postId)] = commentText
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
