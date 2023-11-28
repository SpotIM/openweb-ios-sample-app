//
//  ConversationBelowVideoViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SpotImCore

protocol ConversationBelowVideoViewModelingInputs {}

protocol ConversationBelowVideoViewModelingOutputs {
    var title: String { get }
    var componentRetrievingError: Observable<OWError> { get }
    var preConversationRetrieved: Observable<UIView> { get }
    var conversationRetrieved: Observable<UIView> { get }
    var commentCreationRetrieved: Observable<UIView> { get }
    var clarityDetailsRetrieved: Observable<UIView> { get }
    var webPageRetrieved: Observable<UIView> { get }
    var reportReasonsRetrieved: Observable<UIView> { get }
    var removeConversation: Observable<Void> { get }
    var removeReportReasons: Observable<Void> { get }
    var removeCommentCreation: Observable<Void> { get }
    var removeClarityDetails: Observable<Void> { get }
    var removeWebPage: Observable<Void> { get }
    var openAuthentication: Observable<(OWSpotId, OWBasicCompletion)> { get }
}

protocol ConversationBelowVideoViewModeling {
    var inputs: ConversationBelowVideoViewModelingInputs { get }
    var outputs: ConversationBelowVideoViewModelingOutputs { get }
}

class ConversationBelowVideoViewModel: ConversationBelowVideoViewModeling, ConversationBelowVideoViewModelingOutputs, ConversationBelowVideoViewModelingInputs {

    var inputs: ConversationBelowVideoViewModelingInputs { return self }
    var outputs: ConversationBelowVideoViewModelingOutputs { return self }

    fileprivate let postId: OWPostId
    fileprivate let disposeBag = DisposeBag()
    fileprivate let commonCreatorService: CommonCreatorServicing
    fileprivate let silentSSOAuthentication: SilentSSOAuthenticationNewAPIProtocol

    lazy var title: String = {
        return NSLocalizedString("VideoExample", comment: "")
    }()

    fileprivate let _componentRetrievingError = BehaviorSubject<OWError?>(value: nil)
    var componentRetrievingError: Observable<OWError> {
        return _componentRetrievingError
            .unwrap()
            .asObservable()
    }

    fileprivate let _preConversationRetrieved = BehaviorSubject<UIView?>(value: nil)
    var preConversationRetrieved: Observable<UIView> {
        return _preConversationRetrieved
            .unwrap()
            .asObservable()
    }

    fileprivate let _conversationRetrieved = PublishSubject<UIView>()
    var conversationRetrieved: Observable<UIView> {
        return _conversationRetrieved
            .asObservable()
    }

    fileprivate let _commentCreationRetrieved = PublishSubject<UIView>()
    var commentCreationRetrieved: Observable<UIView> {
        return _commentCreationRetrieved
            .asObservable()
    }

    fileprivate let _reportReasonsRetrieved = PublishSubject<UIView>()
    var reportReasonsRetrieved: Observable<UIView> {
        return _reportReasonsRetrieved
            .asObservable()
    }

    fileprivate let _clarityDetailsRetrieved = PublishSubject<UIView>()
    var clarityDetailsRetrieved: Observable<UIView> {
        return _clarityDetailsRetrieved
            .asObservable()
    }

    fileprivate let _webPageRetrieved = PublishSubject<UIView>()
    var webPageRetrieved: Observable<UIView> {
        return _webPageRetrieved
            .asObservable()
    }

    fileprivate let _removeConversation = PublishSubject<Void>()
    var removeConversation: Observable<Void> {
        return _removeConversation
            .asObservable()
    }

    fileprivate let _removeReportReasons = PublishSubject<Void>()
    var removeReportReasons: Observable<Void> {
        return _removeReportReasons
            .asObservable()
    }

    fileprivate let _removeCommentCreation = PublishSubject<Void>()
    var removeCommentCreation: Observable<Void> {
        return _removeCommentCreation
            .asObservable()
    }

    fileprivate let _removeClarityDetails = PublishSubject<Void>()
    var removeClarityDetails: Observable<Void> {
        return _removeClarityDetails
            .asObservable()
    }

    fileprivate let _removeWebPage = PublishSubject<Void>()
    var removeWebPage: Observable<Void> {
        return _removeWebPage
            .asObservable()
    }

    fileprivate let _openAuthentication = PublishSubject<(OWSpotId, OWBasicCompletion)>()
    var openAuthentication: Observable<(OWSpotId, OWBasicCompletion)> {
        return _openAuthentication
            .asObservable()
    }

    fileprivate lazy var actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
        guard let self = self else { return }

        let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
        DLog(log)

        switch (sourceType, callbackType) {
        case (.preConversation, .contentPressed):
            self.retrieveConversationComponent()
        case (.conversation, .closeConversationPressed):
            self._removeConversation.onNext()
        case (.conversation, .openReportReason(let commentId, let parentId)):
            self.retrieveReportReasonsComponent(commentId: commentId, parentId: parentId)
        case (.reportReason, .closeReportReason):
            self._removeReportReasons.onNext()
        case (.conversation, .openCommentCreation(let commentCreationType)):
            self.retrieveCommentCreationComponent(type: commentCreationType)
        case (.conversation, .openClarityDetails(let clarityDetailsType)):
            self.retrieveClarityDetailsComponent(commentId: "", type: clarityDetailsType)
        case (.clarityDetails, .closeClarityDetails):
            self._removeClarityDetails.onNext()
        case (_, .communityGuidelinesPressed(let url)):
            let title = NSLocalizedString("CommunityGuidelines", comment: "")
            let options = OWWebTabOptions(url: url, title: title)
            self.retrieveWebPageComponent(options: options)
        case (.commentCreation, .floatingCommentCreationDismissed):
            self._removeCommentCreation.onNext()
        case (.webView, .closeWebView):
            self._removeWebPage.onNext()
        case (_, .openOWProfile(let data)):
            let title = NSLocalizedString("ProfileTitle", comment: "")
            let options = OWWebTabOptions(url: data.url, title: title)
            self.retrieveWebPageComponent(options: options)
        case (_, .openLinkInComment(let url)):
            self.retrieveWebPageComponent(options: OWWebTabOptions(url: url, title: ""))
        default:
            break
        }
    }

    // Providing `displayAuthenticationFlow` callback
    fileprivate lazy var authenticationFlowCallback: OWAuthenticationFlowCallback = { [weak self] routeringMode, completion in
        guard let self = self else { return }

        switch routeringMode {
        case .none:
            self._openAuthentication.onNext((OpenWeb.manager.spotId, completion))
        default:
            break
        }
    }

    // Providing `renewSSO` callback
    fileprivate lazy var  renewSSOCallback: OWRenewSSOCallback = { [weak self] userId, completion in
        guard let self = self else { return }
        let demoSpotId = ConversationPreset.demoSpot().conversationDataModel.spotId
        if OpenWeb.manager.spotId == demoSpotId,
           let genericSSO = GenericSSOAuthentication.mockModels.first(where: { $0.user.userId == userId }) {
            _ = self.silentSSOAuthentication.silentSSO(for: genericSSO, ignoreLoginStatus: true)
                .take(1) // No need to disposed since we only take 1
                .subscribe(onNext: { userId in
                    DLog("Silent SSO completed successfully with userId: \(userId)")
                    completion()
                }, onError: { error in
                    DLog("Silent SSO failed with error: \(error)")
                    completion()
                })
        } else {
            DLog("`renewSSOCallback` triggered, but this is not our demo spot: \(demoSpotId)")
            completion()
        }
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

fileprivate extension ConversationBelowVideoViewModel {
    func initialSetup() {
        // Setup authentication flow callback
        var authenticationUI = OpenWeb.manager.ui.authenticationUI
        authenticationUI.displayAuthenticationFlow = authenticationFlowCallback

        // Setup renew SSO callback
        var authentication = OpenWeb.manager.authentication
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

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._preConversationRetrieved.onNext(view)
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

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._conversationRetrieved.onNext(view)
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

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._commentCreationRetrieved.onNext(view)
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

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._reportReasonsRetrieved.onNext(view)
            }
        })
    }

    func retrieveClarityDetailsComponent(commentId: OWCommentId, type: OWClarityDetailsType) {
        let uiViewsLayer = OpenWeb.manager.ui.views
        let additionalSettings = OWAdditionalSettings()

        uiViewsLayer.clarityDetails(postId: self.postId,
                                  commentId: commentId,
                                  type: type,
                                  additionalSettings: additionalSettings,
                                  callbacks: self.actionsCallbacks,
                                  completion: { [weak self] result in

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._clarityDetailsRetrieved.onNext(view)
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

            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self._componentRetrievingError.onNext(err)
            case.success(let view):
                self._webPageRetrieved.onNext(view)
            }
        })
    }
}
