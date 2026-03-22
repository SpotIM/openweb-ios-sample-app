//
//  UIViewsConversationBelowVideoViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import OpenWebSDK

protocol UIViewsConversationBelowVideoViewModelingInputs {}

protocol UIViewsConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: AnyPublisher<OWError, Never> { get }
    var preConversationRetrieved: AnyPublisher<UIView, Never> { get }
    var conversationRetrieved: AnyPublisher<UIView, Never> { get }
    var commentCreationRetrieved: AnyPublisher<UIView, Never> { get }
    var notificationsRetrieved: AnyPublisher<UIView, Never> { get }
    var clarityDetailsRetrieved: AnyPublisher<UIView, Never> { get }
    var webPageRetrieved: AnyPublisher<UIView, Never> { get }
    var reportReasonsRetrieved: AnyPublisher<UIView, Never> { get }
    var commentThreadRetrieved: AnyPublisher<UIView, Never> { get }
    var removeConversation: AnyPublisher<Void, Never> { get }
    var removeReportReasons: AnyPublisher<Void, Never> { get }
    var removeCommentCreation: AnyPublisher<Void, Never> { get }
    var removeNotifications: AnyPublisher<Void, Never> { get }
    var removeClarityDetails: AnyPublisher<Void, Never> { get }
    var removeCommentThread: AnyPublisher<Void, Never> { get }
    var removeWebPage: AnyPublisher<Void, Never> { get }
    var openAuthentication: AnyPublisher<(OWSpotId, OWBasicCompletion), Never> { get }
    var videoExampleViewModel: VideoExampleViewModeling { get }
}

protocol UIViewsConversationBelowVideoViewModeling {
    var inputs: UIViewsConversationBelowVideoViewModelingInputs { get }
    var outputs: UIViewsConversationBelowVideoViewModelingOutputs { get }
}

class UIViewsConversationBelowVideoViewModel: UIViewsConversationBelowVideoViewModeling, UIViewsConversationBelowVideoViewModelingOutputs, UIViewsConversationBelowVideoViewModelingInputs {
    var inputs: UIViewsConversationBelowVideoViewModelingInputs { return self }
    var outputs: UIViewsConversationBelowVideoViewModelingOutputs { return self }

    private let postId: OWPostId
    private let commonCreatorService: CommonCreatorServicing

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    let videoExampleViewModel: VideoExampleViewModeling = VideoExampleViewModel()

    private let _componentRetrievingError = CurrentValueSubject<OWError?, Never>(value: nil)
    var componentRetrievingError: AnyPublisher<OWError, Never> {
        return _componentRetrievingError
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _preConversationRetrieved = CurrentValueSubject<UIView?, Never>(value: nil)
    var preConversationRetrieved: AnyPublisher<UIView, Never> {
        return _preConversationRetrieved
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _conversationRetrieved = PassthroughSubject<UIView, Never>()
    var conversationRetrieved: AnyPublisher<UIView, Never> {
        return _conversationRetrieved
            .eraseToAnyPublisher()
    }

    private let _commentCreationRetrieved = PassthroughSubject<UIView, Never>()
    var commentCreationRetrieved: AnyPublisher<UIView, Never> {
        return _commentCreationRetrieved
            .eraseToAnyPublisher()
    }

    private let _notificationsRetrieved = PassthroughSubject<UIView, Never>()
    var notificationsRetrieved: AnyPublisher<UIView, Never> {
        return _notificationsRetrieved
            .eraseToAnyPublisher()
    }

    private let _reportReasonsRetrieved = PassthroughSubject<UIView, Never>()
    var reportReasonsRetrieved: AnyPublisher<UIView, Never> {
        return _reportReasonsRetrieved
            .eraseToAnyPublisher()
    }

    private let _commentThreadRetrieved = PassthroughSubject<UIView, Never>()
    var commentThreadRetrieved: AnyPublisher<UIView, Never> {
        return _commentThreadRetrieved
            .eraseToAnyPublisher()
    }

    private let _clarityDetailsRetrieved = PassthroughSubject<UIView, Never>()
    var clarityDetailsRetrieved: AnyPublisher<UIView, Never> {
        return _clarityDetailsRetrieved
            .eraseToAnyPublisher()
    }

    private let _webPageRetrieved = PassthroughSubject<UIView, Never>()
    var webPageRetrieved: AnyPublisher<UIView, Never> {
        return _webPageRetrieved
            .eraseToAnyPublisher()
    }

    private let _removeConversation = PassthroughSubject<Void, Never>()
    var removeConversation: AnyPublisher<Void, Never> {
        return _removeConversation
            .eraseToAnyPublisher()
    }

    private let _removeReportReasons = PassthroughSubject<Void, Never>()
    var removeReportReasons: AnyPublisher<Void, Never> {
        return _removeReportReasons
            .eraseToAnyPublisher()
    }

    private let _removeCommentCreation = PassthroughSubject<Void, Never>()
    var removeCommentCreation: AnyPublisher<Void, Never> {
        return _removeCommentCreation
            .eraseToAnyPublisher()
    }

    private let _removeNotifications = PassthroughSubject<Void, Never>()
    var removeNotifications: AnyPublisher<Void, Never> {
        return _removeNotifications
            .eraseToAnyPublisher()
    }

    private let _removeClarityDetails = PassthroughSubject<Void, Never>()
    var removeClarityDetails: AnyPublisher<Void, Never> {
        return _removeClarityDetails
            .eraseToAnyPublisher()
    }

    private let _removeCommentThread = PassthroughSubject<Void, Never>()
    var removeCommentThread: AnyPublisher<Void, Never> {
        return _removeCommentThread
            .eraseToAnyPublisher()
    }

    private let _removeWebPage = PassthroughSubject<Void, Never>()
    var removeWebPage: AnyPublisher<Void, Never> {
        return _removeWebPage
            .eraseToAnyPublisher()
    }

    private let _openAuthentication = PassthroughSubject<(OWSpotId, OWBasicCompletion), Never>()
    var openAuthentication: AnyPublisher<(OWSpotId, OWBasicCompletion), Never> {
        return _openAuthentication
            .eraseToAnyPublisher()
    }

    private lazy var actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
        guard let self else { return }

        let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
        DLog(log)

        switch (sourceType, callbackType) {
        case (.preConversation, .contentPressed):
            retrieveConversationComponent()
        case (.conversation, .closeConversationPressed):
            _removeConversation.send()
        case (.conversation, .openReportReason(let commentId, let parentId)):
            retrieveReportReasonsComponent(commentId: commentId, parentId: parentId)
        case (.reportReason, .closeReportReason):
            _removeReportReasons.send()
        case (.conversation, .openCommentCreation(let commentCreationType)):
            retrieveCommentCreationComponent(type: commentCreationType)
        case (.conversation, .openClarityDetails(let data)):
            retrieveClarityDetailsComponent(data: data)
        case (.commentThread, .openCommentCreation(let commentCreationType)):
            retrieveCommentCreationComponent(type: commentCreationType)
        case (.clarityDetails, .closeClarityDetails):
            _removeClarityDetails.send()
        case (.commenterAppeal, .closeClarityDetails):
            _removeClarityDetails.send()
        case (_, .openCommenterAppeal(let data)):
            retrieveCommenterAppealComponent(data: data)
        case (_, .communityGuidelinesPressed(let url)):
            let title = NSLocalizedString("CommunityGuidelines", comment: "")
            let options = OWWebTabOptions(url: url, title: title)
            retrieveWebPageComponent(options: options)
        case (.commentCreation, .floatingCommentCreationDismissed):
            _removeCommentCreation.send()
        case (.commentCreation, .reviewSubmitted):
            _removeCommentCreation.send()
        case (.webView, .closeWebView):
            _removeWebPage.send()
        case (_, .openOWProfile(let data)):
            let title = NSLocalizedString("ProfileTitle", comment: "")
            let options = OWWebTabOptions(url: data.url, title: title)
            retrieveWebPageComponent(options: options)
        case (_, .openLinkInComment(let url)):
            retrieveWebPageComponent(options: OWWebTabOptions(url: url, title: ""))
        case (_, .openCommentThread(let commentId, let postId, let performActionType)):
            retrieveCommentThreadComponent(
                commentId: commentId,
                postId: postId,
                performActionType: performActionType
            )
        case (.commentThread, .closeCommentThread):
            _removeCommentThread.send()
        case (.conversation, .openNotifications):
            retrieveNotificationsComponent()
        case (.notifications, .closeNotifications):
            _removeNotifications.send()
        default:
            break
        }
    }

    // Providing `displayAuthenticationFlow` callback
    private lazy var authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] routeringMode, completion in
        guard let self else { return }

        switch routeringMode {
        case .none:
            _openAuthentication.send((OpenWeb.manager.spotId, completion))
        default:
            break
        }
    }

    init(
        postId: OWPostId,
        commonCreatorService: CommonCreatorServicing = CommonCreatorService()
    ) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        setupObservers()
        initialSetup()
    }
}

private extension UIViewsConversationBelowVideoViewModel {
    func initialSetup() {
        // Setup authentication flow callback
        let authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Setup renew SSO callback
        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = commonCreatorService.renewSSOCallback

        // We are going to retrieve pre conversation component as soon as the user entered the screen.
        // We even perform the API in the init of the VM to speed things up
        retrievePreConversationComponent()
    }
    func setupObservers() {}

    func retrievePreConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(preConversationSettings: OWPreConversationSettings(style: .compact))

        uiViewsLayer.preConversation(
            postId: postId,
            article: article,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _preConversationRetrieved.send(view)
            }
            }
        )
    }

    func retrieveConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(fullConversationSettings: OWConversationSettings(style: .compact))

        uiViewsLayer.conversation(
            postId: postId,
            article: article,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _conversationRetrieved.send(view)
            }
            }
        )
    }

    func retrieveCommentCreationComponent(type: OWCommentCreationType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        uiViewsLayer.commentCreation(
            postId: postId,
            article: article,
            commentCreationType: type,
            additionalSettings: OWAdditionalSettings(),
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _commentCreationRetrieved.send(view)
            }
            }
        )
    }

    func retrieveReportReasonsComponent(commentId: OWCommentId, parentId: OWCommentId) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.reportReason(
            postId: postId,
            commentId: commentId,
            parentId: parentId,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _reportReasonsRetrieved.send(view)
            }
            }
        )
    }

    func retrieveNotificationsComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()
        let article = commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        uiViewsLayer.notifications(
            postId: postId,
            article: article,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _notificationsRetrieved.send(view)
            }
            }
        )
    }

    func retrieveClarityDetailsComponent(data: OWClarityDetailsRequireData) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.clarityDetails(
            postId: postId,
            commentId: data.commentId,
            type: data.type,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _clarityDetailsRetrieved.send(view)
            }
            }
        )
    }

    func retrieveCommenterAppealComponent(data: OWAppealRequiredData) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.commenterAppeal(
            postId: postId,
            data: data,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _clarityDetailsRetrieved.send(view)
            }
            }
        )
    }

    func retrieveCommentThreadComponent(commentId: OWCommentId, postId: OWPostId, performActionType: OWCommentThreadPerformActionType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let commentThreadSettings = OWCommentThreadSettings(performActionType: performActionType)
        let additionalSettings = OWAdditionalSettings(commentThreadSettings: commentThreadSettings)

        uiViewsLayer.commentThread(
            postId: postId,
            article: article,
            commentId: commentId,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _commentThreadRetrieved.send(view)
            }
            }
        )
    }

    func retrieveWebPageComponent(options: OWWebTabOptions) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.webTab(
            postId: postId,
            tabOptions: options,
            additionalSettings: additionalSettings,
            callbacks: actionsCallbacks,
            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                _componentRetrievingError.send(err)
            case .success(let view):
                _webPageRetrieved.send(view)
            }
            }
        )
    }
}
