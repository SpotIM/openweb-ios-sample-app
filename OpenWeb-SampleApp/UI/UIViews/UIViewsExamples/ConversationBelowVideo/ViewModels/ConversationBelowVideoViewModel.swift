//
//  ConversationBelowVideoViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Combine
import OpenWebSDK
#if !PUBLIC_DEMO_APP
import OpenWeb_SampleApp_Internal_Configs
#endif

protocol ConversationBelowVideoViewModelingInputs {}

protocol ConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: AnyPublisher<OWError, Never> { get }
    var preConversationRetrieved: AnyPublisher<UIView, Never> { get }
    var conversationRetrieved: AnyPublisher<UIView, Never> { get }
    var commentCreationRetrieved: AnyPublisher<UIView, Never> { get }
    var clarityDetailsRetrieved: AnyPublisher<UIView, Never> { get }
    var webPageRetrieved: AnyPublisher<UIView, Never> { get }
    var reportReasonsRetrieved: AnyPublisher<UIView, Never> { get }
    var commentThreadRetrieved: AnyPublisher<UIView, Never> { get }
    var removeConversation: AnyPublisher<Void, Never> { get }
    var removeReportReasons: AnyPublisher<Void, Never> { get }
    var removeCommentCreation: AnyPublisher<Void, Never> { get }
    var removeClarityDetails: AnyPublisher<Void, Never> { get }
    var removeCommentThread: AnyPublisher<Void, Never> { get }
    var removeWebPage: AnyPublisher<Void, Never> { get }
    var openAuthentication: AnyPublisher<(OWSpotId, OWBasicCompletion), Never> { get }
}

protocol ConversationBelowVideoViewModeling {
    var inputs: ConversationBelowVideoViewModelingInputs { get }
    var outputs: ConversationBelowVideoViewModelingOutputs { get }
}

class ConversationBelowVideoViewModel: ConversationBelowVideoViewModeling, ConversationBelowVideoViewModelingOutputs, ConversationBelowVideoViewModelingInputs {

    var inputs: ConversationBelowVideoViewModelingInputs { return self }
    var outputs: ConversationBelowVideoViewModelingOutputs { return self }

    private let postId: OWPostId
    private let commonCreatorService: CommonCreatorServicing
    private let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

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
            self.retrieveConversationComponent()
        case (.conversation, .closeConversationPressed):
            self._removeConversation.send()
        case (.conversation, .openReportReason(let commentId, let parentId)):
            self.retrieveReportReasonsComponent(commentId: commentId, parentId: parentId)
        case (.reportReason, .closeReportReason):
            self._removeReportReasons.send()
        case (.conversation, .openCommentCreation(let commentCreationType)):
            self.retrieveCommentCreationComponent(type: commentCreationType)
        case (.conversation, .openClarityDetails(let data)):
            self.retrieveClarityDetailsComponent(data: data)
        case (.commentThread, .openCommentCreation(let commentCreationType)):
            self.retrieveCommentCreationComponent(type: commentCreationType)
        case (.clarityDetails, .closeClarityDetails):
            self._removeClarityDetails.send()
        case (.commenterAppeal, .closeClarityDetails):
            self._removeClarityDetails.send()
        case (_, .openCommenterAppeal(let data)):
            self.retrieveCommenterAppealComponent(data: data)
        case (_, .communityGuidelinesPressed(let url)):
            let title = NSLocalizedString("CommunityGuidelines", comment: "")
            let options = OWWebTabOptions(url: url, title: title)
            self.retrieveWebPageComponent(options: options)
        case (.commentCreation, .floatingCommentCreationDismissed):
            self._removeCommentCreation.send()
        case (.webView, .closeWebView):
            self._removeWebPage.send()
        case (_, .openOWProfile(let data)):
            let title = NSLocalizedString("ProfileTitle", comment: "")
            let options = OWWebTabOptions(url: data.url, title: title)
            self.retrieveWebPageComponent(options: options)
        case (_, .openLinkInComment(let url)):
            self.retrieveWebPageComponent(options: OWWebTabOptions(url: url, title: ""))
        case (_, .openCommentThread(let commentId, let performActionType)):
            self.retrieveCommentThreadComponent(commentId: commentId,
                                                performActionType: performActionType)
        case (.commentThread, .closeCommentThread):
            self._removeCommentThread.send()
        default:
            break
        }
    }

    // Providing `displayAuthenticationFlow` callback
    private lazy var authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] routeringMode, completion in
        guard let self else { return }

        switch routeringMode {
        case .none:
            self._openAuthentication.send((OpenWeb.manager.spotId, completion))
        default:
            break
        }
    }

    // Providing `renewSSO` callback
    private lazy var  renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
        guard let self else { return }
        #if !PUBLIC_DEMO_APP
        let demoSpotId = DevelopmentConversationPreset.demoSpot().toConversationPreset().conversationDataModel.spotId
        if OpenWeb.manager.spotId == demoSpotId,
           let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
            _ = self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                .asPublisher()
                .prefix(1) // No need to disposed since we only take 1
                .sink(receiveCompletion: { result in
                    if case .failure(let error) = result {
                        DLog("Silent SSO failed with error: \(error)")
                        completion()
                    }
                }, receiveValue: { userId in
                    DLog("Silent SSO completed successfully with userId: \(userId)")
                    completion()
                })
        } else {
            DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
            completion()
        }
        #else
        DLog("`renewSSOCallback` triggered")
        #endif
    }

    init(postId: OWPostId,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService(),
         silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol = SilentSSOAuthenticationNewAPI()) {
        self.postId = postId
        self.commonCreatorService = commonCreatorService
        self.silentSSOAuthentication = silentSSOAuthentication
        setupObservers()
        initialSetup()
    }
}

private extension ConversationBelowVideoViewModel {
    func initialSetup() {
        // Setup authentication flow callback
        let authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Setup renew SSO callback
        let authentication = OpenWeb.manager.authentication
        authentication.renewSSO = renewSSOCallback

        // We are going to retrieve pre conversation component as soon as the user entered the screen.
        // We even perform the API in the init of the VM to speed things up
        retrievePreConversationComponent()
    }
    func setupObservers() {}

    func retrievePreConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(preConversationSettings: OWPreConversationSettings(style: .compact))

        uiViewsLayer.preConversation(postId: self.postId,
                                     article: article,
                                     additionalSettings: additionalSettings,
                                     callbacks: self.actionsCallbacks,
                                     completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._preConversationRetrieved.send(view)
            }
        })
    }

    func retrieveConversationComponent() {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let additionalSettings = OWAdditionalSettings(fullConversationSettings: OWConversationSettings(style: .compact))

        uiViewsLayer.conversation(postId: self.postId,
                                  article: article,
                                  additionalSettings: additionalSettings,
                                  callbacks: self.actionsCallbacks,
                                  completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._conversationRetrieved.send(view)
            }
        })
    }

    func retrieveCommentCreationComponent(type: OWCommentCreationType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        // Always show accessory view in the floating keyboard for this example of conversation below video
        let floatingBottomToolbarTuple = commonCreatorService.commentCreationFloatingBottomToolbar()
        let toolbar = floatingBottomToolbarTuple.1
        let toolbarVM = floatingBottomToolbarTuple.0
        let accessoryViewStrategy = OWAccessoryViewStrategy.bottomToolbar(toolbar: toolbar)
        let commentCreationStyle: OWCommentCreationStyle = .floatingKeyboard(accessoryViewStrategy: accessoryViewStrategy)
        let commentCreationSettings = OWCommentCreationSettings(style: commentCreationStyle)
        // Inject the settings into the toolbar VM
        toolbarVM.inputs.setCommentCreationSettings(commentCreationSettings)
        let additionalSettings = OWAdditionalSettings(commentCreationSettings: commentCreationSettings)

        uiViewsLayer.commentCreation(postId: self.postId,
                                     article: article,
                                     commentCreationType: type,
                                     additionalSettings: additionalSettings,
                                     callbacks: self.actionsCallbacks,
                                     completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._commentCreationRetrieved.send(view)
            }
        })
    }

    func retrieveReportReasonsComponent(commentId: OWCommentId, parentId: OWCommentId) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.reportReason(postId: self.postId,
                                  commentId: commentId,
                                  parentId: parentId,
                                  additionalSettings: additionalSettings,
                                  callbacks: self.actionsCallbacks,
                                  completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._reportReasonsRetrieved.send(view)
            }
        })
    }

    func retrieveClarityDetailsComponent(data: OWClarityDetailsRequireData) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.clarityDetails(postId: self.postId,
                                    commentId: data.commentId,
                                    type: data.type,
                                    additionalSettings: additionalSettings,
                                    callbacks: self.actionsCallbacks,
                                    completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._clarityDetailsRetrieved.send(view)
            }
        })
    }

    func retrieveCommenterAppealComponent(data: OWAppealRequiredData) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.commenterAppeal(postId: self.postId,
                                     data: data,
                                     additionalSettings: additionalSettings,
                                     callbacks: self.actionsCallbacks,
                                     completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._clarityDetailsRetrieved.send(view)
            }
        })
    }

    func  retrieveCommentThreadComponent(commentId: OWCommentId, performActionType: OWCommentThreadPerformActionType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let article = self.commonCreatorService.mockArticle(for: OpenWeb.manager.spotId)

        let commentThreadSettings = OWCommentThreadSettings(performActionType: performActionType)
        let additionalSettings = OWAdditionalSettings(commentThreadSettings: commentThreadSettings)

        uiViewsLayer.commentThread(postId: self.postId,
                                   article: article,
                                   commentId: commentId,
                                   additionalSettings: additionalSettings,
                                   callbacks: self.actionsCallbacks,
                                   completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._commentThreadRetrieved.send(view)
            }
        })
    }

    func retrieveWebPageComponent(options: OWWebTabOptions) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.webTab(postId: self.postId,
                            tabOptions: options,
                            additionalSettings: additionalSettings,
                            callbacks: self.actionsCallbacks,
                            completion: { [weak self] result in

            guard let self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.send(err)
            case.success(let view):
                self._webPageRetrieved.send(view)
            }
        })
    }
}
