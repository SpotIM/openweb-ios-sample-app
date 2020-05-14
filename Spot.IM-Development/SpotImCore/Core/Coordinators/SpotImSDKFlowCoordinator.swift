//
//  SpotImSDKFlowCoordinator.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/6/19.
//  Copyright (c) 2019 Spot.IM. All rights reserved.
//
//

import UIKit
import SafariServices

public protocol SpotImSDKNavigationDelegate: AnyObject {
    func controllerForSSOFlow() -> UIViewController
}

public protocol SpotImLayoutDelegate: AnyObject {
    func viewHeightDidChange(to newValue: CGFloat)
}

public protocol AuthenticationViewDelegate: AnyObject {
    func authenticationStarted()
}

public protocol SpotImLoginDelegate: AnyObject {
    func startLoginFlow()
}

final public class SpotImSDKFlowCoordinator: Coordinator {
    
    weak var containerViewController: UIViewController?
    
    // MARK: - Services
    
    private lazy var commentsCacheService: SPCommentsInMemoryCacheService = .init()
    
    private lazy var conversationUpdater: SPCommentUpdater = SPCommentFacade()
    
    private weak var sdkNavigationDelegate: SpotImSDKNavigationDelegate?
    private weak var spotLayoutDelegate: SpotImLayoutDelegate?
    private weak var loginDelegate: SpotImLoginDelegate?
    
    private var localCommentReplyDidCreate: ((SPComment) -> Void)?
    private var commentReplyCreationBlocked: ((String?) -> Void)?
    private var authHandlers: [WeakRef<AuthenticationHandler>] = []
    private var configCompletion: ((UIViewController) -> Void)?
    private var postId: String?
    private var shouldAddMain: Bool = false
    private var conversationModel: SPMainConversationModel!
    private let adsManager: AdsManager
    private let apiManager: ApiManager
    private let imageProvider: SPImageURLProvider
    private let realTimeService: RealTimeService
    private let spotConfig: SpotConfig
    private var preConversationViewController: UIViewController?
    private weak var authenticationViewDelegate: AuthenticationViewDelegate?
    
    ///If inputConfiguration parameter is nil Localization settings will be taken from server config
    internal init(spotConfig: SpotConfig, delegate: SpotImSDKNavigationDelegate, spotId: String, localeId: String?) {
        sdkNavigationDelegate = delegate
        adsManager = AdsManager(spotId: spotId)
        apiManager = ApiManager()
        self.spotConfig = spotConfig
        realTimeService = RealTimeService(realTimeDataProvider: DefaultRealtimeDataProvider(apiManager: apiManager))
        imageProvider = SPCloudinaryImageProvider(apiManager: apiManager)
        
        configureAPIAndRealTimeHandlers()
        
        if let localeId = localeId {
            LocalizationManager.setLocale(localeId)
        }
    }
    
    internal init(spotConfig: SpotConfig, loginDelegate: SpotImLoginDelegate, spotId: String, localeId: String?) {
        self.loginDelegate = loginDelegate
        adsManager = AdsManager(spotId: spotId)
        apiManager = ApiManager()
        self.spotConfig = spotConfig
        realTimeService = RealTimeService(realTimeDataProvider: DefaultRealtimeDataProvider(apiManager: apiManager))
        imageProvider = SPCloudinaryImageProvider(apiManager: apiManager)
        
        configureAPIAndRealTimeHandlers()
        
        if let localeId = localeId {
            LocalizationManager.setLocale(localeId)
        }
    }
    
    public func setLayoutDelegate(delegate: SpotImLayoutDelegate) {
        self.spotLayoutDelegate = delegate
    }

    /// Please, provide container (UINavigationViewController) for sdk flows
    public func preConversationController(withPostId postId: String,
                                          articleMetadata: SpotImArticleMetadata,
                                          numberOfPreLoadedMessages: Int = 2,
                                          navigationController: UINavigationController,
                                          completion: @escaping (UIViewController) -> Void) {
        containerViewController = navigationController
        buildPreConversationController(with: postId, articleMetadata: articleMetadata, numberOfPreLoadedMessages: numberOfPreLoadedMessages, completion: completion)
    }

    private func startFlow(with controller: SPMainConversationViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }

    private func buildPreConversationController(with postId: String, articleMetadata: SpotImArticleMetadata, numberOfPreLoadedMessages: Int, completion: @escaping (UIViewController) -> Void) {
        SPAnalyticsHolder.default.prepareForNewPage()

        let conversationDataProvider = SPConversationsFacade(apiManager: apiManager)
        let conversationDataSource = SPMainConversationDataSource(
            with: postId,
            articleMetadata: articleMetadata,
            dataProvider: conversationDataProvider
        )
        conversationDataProvider.imageURLProvider = imageProvider
        let conversationModel = SPMainConversationModel(
            commentUpdater: conversationUpdater,
            conversationDataSource: conversationDataSource,
            imageProvider: imageProvider,
            realTimeService: realTimeService,
            abTestData: spotConfig.abConfig
        )
        self.conversationModel = conversationModel
        realTimeService.delegate = self.conversationModel
        
        let preConversationViewController = SPPreConversationViewController(model: conversationModel, numberOfMessagesToShow: numberOfPreLoadedMessages, adsProvider: adsManager.adsProvider())
        
        self.conversationModel.delegates.add(delegate: preConversationViewController)
        self.conversationModel.commentsCounterDelegates.add(delegate: preConversationViewController)
        
        preConversationViewController.delegate = self
        preConversationViewController.preConversationDelegate = self
        preConversationViewController.dataLoaded = { [weak self] in
            guard let preConversationViewController = self?.preConversationViewController else { return }
            
            self?.preConversationViewController = nil
            completion(preConversationViewController)
        }
        
        self.preConversationViewController = preConversationViewController
    }

    private func conversationController(with model: SPMainConversationModel) -> SPMainConversationViewController {
        let controller = SPMainConversationViewController(model: model, adsProvider: adsManager.adsProvider())
    
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        
        controller.title = LocalizationManager.localizedString(key: "Conversation")
        
        Logger.verbose("FirstComment: localCommentReplayDidCreate SET")
        localCommentReplyDidCreate = { comment in
            Logger.verbose("FirstComment: localCommentReplayDidCreate CALLED")
            Logger.verbose("FirstComment: setting the pending comment to the model")
            model.pendingComment = comment
        }
        commentReplyCreationBlocked = { commentText in
            model.handleMessageCreationBlockage(with: commentText)
        }

        authHandlers.append(WeakRef(value: controller.userDidSignInHandler()))
        return controller
    }

    private func presentContentCreationViewController<T: CommentStateable>(controller: CommentReplyViewController<T>,
                                                                           _ dataModel: SPMainConversationModel) {
        let lastViewController = navigationController?.viewControllers.last
        shouldAddMain = !(lastViewController?.isKind(of: SPMainConversationViewController.self) ?? true)

        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .moveIn
        transition.subtype = .fromTop

        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
        authHandlers.append(WeakRef(value: controller.userDidSignInHandler()))
        authenticationViewDelegate = controller
    }

    private func insertMainConversationToNavigation(_ dataModel: SPMainConversationModel) {
        let controller = conversationController(with: dataModel)
        let index = (navigationController?.viewControllers.count ?? 1) - 1
        navigationController?.viewControllers.insert(controller, at: index)
    }

    @objc
    private func closeMainConversation() {
        containerViewController?.dismiss(animated: true, completion: nil)
    }

    private func showWebPage(with urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let safariController = SFSafariViewController(url: url)
        navigationController?.present(safariController, animated: true)
    }
    
    ///Handles any successfull request and refreshes `RealTimeService` if needed
    private func configureAPIAndRealTimeHandlers() {
        apiManager.requestDidSucceed = { [weak self] request in
            guard let strongSelf = self else { return }
            switch request {
            case _ as SPConversationRequest: strongSelf.realTimeService.refreshService()
                
            default: break
            }
        }
    }
}

extension SpotImSDKFlowCoordinator: SPCommentsCreationDelegate {

    internal func createComment(with dataModel: SPMainConversationModel) {
        let controller = SPCommentCreationViewController()
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        
        let model = SPCommentCreationModel(commentCreationDTO: dataModel.dataSource.commentCreationModel(),
                                           cacheService: commentsCacheService,
                                           imageProvider: imageProvider)
        controller.model = model
        dataModel.dataSource.showReplies = true
        presentContentCreationViewController(controller: controller, dataModel)
    }
    
    internal func createReply(with dataModel: SPMainConversationModel, to id: String) {
        let controller = SPReplyCreationViewController()
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        
        let model = SPReplyCreationModel(replyCreationDTO: dataModel.dataSource.replyCreationModel(for: id),
                                         cacheService: commentsCacheService,
                                         imageProvider: imageProvider)
        controller.model = model
        dataModel.dataSource.showReplies = true
        
        presentContentCreationViewController(controller: controller, dataModel)
    }
}

extension SpotImSDKFlowCoordinator: SPPreConversationViewControllerDelegate {
    internal func showMoreComments(with dataModel: SPMainConversationModel, selectedCommentId: String?) {
        let controller = conversationController(with: dataModel)
        controller.commentIdToShowOnOpen = selectedCommentId
        dataModel.dataSource.showReplies = true
        startFlow(with: controller)
    }

    internal func showTerms() {
        let urlString = spotConfig.appConfig.mobileSdk.openwebBrandUpdated ? spotConfig.appConfig.mobileSdk.openwebTermsUrl : APIConstants.termsURLString
        showWebPage(with: urlString)
    }

    internal func showPrivacy() {
        let urlString = spotConfig.appConfig.mobileSdk.openwebBrandUpdated ? spotConfig.appConfig.mobileSdk.openwebPrivacyUrl : APIConstants.privacyURLString
        showWebPage(with: urlString)
    }

    internal func showAddSpotIM() {
        let urlString = spotConfig.appConfig.mobileSdk.openwebBrandUpdated ? spotConfig.appConfig.mobileSdk.openwebWebsiteUrl : APIConstants.joinURLString
        showWebPage(with: urlString)
    }
    
    internal func viewHeightDidChange(to height: CGFloat) {
        self.spotLayoutDelegate?.viewHeightDidChange(to: height)
    }

}

extension SpotImSDKFlowCoordinator: UserAuthFlowDelegate {
    internal func presentAuth() {
        SpotIm.authProvider.ssoAuthDelegate = self
        if let loginDelegate = self.loginDelegate {
            loginDelegate.startLoginFlow()
        } else if let controller = sdkNavigationDelegate?.controllerForSSOFlow() {
            let container = UINavigationController(rootViewController: controller)
            let barItem = UIBarButtonItem(title: "Back",
                                          style: .plain,
                                          target: self,
                                          action: #selector(hidePresentedViewController))
            controller.navigationItem.setLeftBarButton(barItem, animated: false)
            controller.modalPresentationStyle = .fullScreen
            navigationController?.present(container, animated: true, completion: nil)
        }
    }
}

extension SpotImSDKFlowCoordinator: CommentReplyViewControllerDelegate {
    
    internal func commentReplyDidCreate(_ comment: SPComment) {
        Logger.verbose("FirstComment: Did received comment in delegate")
        if shouldAddMain {
            Logger.verbose("FirstComment: Adding main conversation screen before we continue")
            insertMainConversationToNavigation(conversationModel)
        }
        localCommentReplyDidCreate?(comment)
    }

    internal func commentReplyDidBlock(with commentText: String?) {
        commentReplyCreationBlocked?(commentText)
    }
    
    @objc
    private func hidePresentedViewController() {
        if let _ = sdkNavigationDelegate {
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension SpotImSDKFlowCoordinator: SSOAthenticationDelegate {
    public func ssoFlowStarted() {
        authenticationViewDelegate?.authenticationStarted()
    }
    
    public func ssoFlowDidSucceed() {
        hidePresentedViewController()
        authHandlers.forEach { $0.value?.authHandler?(true) }
    }
    
    public func ssoFlowDidFail(with error: Error?) {
        hidePresentedViewController()
    }
    
    public func userLogout() {
        authHandlers.forEach { $0.value?.authHandler?(false) }
    }
}
