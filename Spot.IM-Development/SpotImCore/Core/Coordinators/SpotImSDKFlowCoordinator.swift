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

public protocol SSOAuthenticatable: class {
    
    var ssoAuthProvider: SPAuthenticationProvider { get }
    
}

public protocol SSOAthenticationDelegate: class {
    
    func ssoFlowDidSucceed()
    func ssoFlowDidFail(with error: Error?)
}

public protocol SpotImSDKNavigationDelegate: class {
    
    func controllerForSSOFlow() -> UIViewController & SSOAuthenticatable
    
}

public protocol SpotImLayoutDelegate: class {
    func viewHeightDidChange(to newValue: CGFloat)
}

extension SpotImSDKNavigationDelegate {
    
    func userDidBecomeUnauthorized() { /* empty default realization, in order to make this function optional */ }
    
}

final public class SpotImSDKFlowCoordinator: Coordinator {
    
    weak var containerViewController: UIViewController?
    
    // MARK: - Services
    
    private lazy var commentsCacheService: SPCommentsInMemoryCacheService = .init()
    
    private lazy var conversationUpdater: SPCommentUpdater = SPCommentFacade()
    
    private weak var sdkNavigationDelegate: SpotImSDKNavigationDelegate?
    private weak var spotLayoutDelegate: SpotImLayoutDelegate?
    
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
    private let realTimeService: RealTimeService?
    
    ///If inputConfiguration parameter is nil Localization settings will be taken from server config
    public init(delegate: SpotImSDKNavigationDelegate, inputConfiguration: InputConfiguration? = nil) {
        sdkNavigationDelegate = delegate
        adsManager = AdsManager()
        apiManager = ApiManager()
        realTimeService = RealTimeService(realTimeDataProvider: DefaultRealtimeDataProvider(apiManager: apiManager))
        imageProvider = SPCloudinaryImageProvider(apiManager: apiManager)
        
        configureAPIAndRealTimeHandlers()
        LocalizationManager.updateLocalizationConfiguration(inputConfiguration)
    }

    public func setLayoutDelegate(delegate: SpotImLayoutDelegate) {
        self.spotLayoutDelegate = delegate
    }

    /// Please, provide container (UINavigationViewController) for sdk flows
    public func preConversationController(withPostId postId: String,
                                          container: UIViewController?,
                                          completion: @escaping (UIViewController) -> Void) {
        containerViewController = container
        
        if let config = SPConfigsDataSource.appConfig {
            if config.mobileSdk?.enabled ?? false {
                LocalizationManager.setLocale(config.mobileSdk?.locale)
                buildPreConversationController(with: postId, completion: completion)
            }
        } else {
            self.postId = postId
            configCompletion = completion
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(respondToConfigUpdate),
                name: .spotIMConfigLoaded,
                object: nil
            )
        }
    }

    @objc
    private func respondToConfigUpdate() {
        if let config = SPConfigsDataSource.appConfig, (config.mobileSdk?.enabled ?? false), let postId = postId, let completion = configCompletion {
            LocalizationManager.setLocale(config.mobileSdk?.locale)
            buildPreConversationController(with: postId, completion: completion)
        }

        self.postId = nil
        configCompletion = nil
    }

    private func startFlow(with controller: SPMainConversationViewController) {
        navigationController?.pushViewController(controller, animated: true)
    }

    private func buildPreConversationController(with postId: String, completion: @escaping (UIViewController) -> Void) {
        SPAnalyticsHolder.default.prepareForNewPage()

        let conversationDataProvider = SPConversationsFacade(apiManager: apiManager)
        let conversationDataSource = SPMainConversationDataSource(
            with: postId,
            dataProvider: conversationDataProvider
        )
        conversationDataProvider.imageURLProvider = imageProvider
        let conversationModel = SPMainConversationModel(
            commentUpdater: conversationUpdater,
            conversationDataSource: conversationDataSource,
            imageProvider: imageProvider,
            realTimeService: realTimeService
        )
        self.conversationModel = conversationModel
        realTimeService?.delegate = self.conversationModel
        let controller = SPPreConversationViewController(model: conversationModel)
        self.conversationModel.delegates.add(delegate: controller)
        controller.adsProvider = adsManager.adsProvider()
        controller.delegate = self
        controller.preConversationDelegate = self
        controller.dataLoaded = {
            completion(controller)
        }
    }

    private func conversationController(with model: SPMainConversationModel) -> SPMainConversationViewController {
        let controller = SPMainConversationViewController(model: model)
    
        controller.adsProvider = adsManager.adsProvider()
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        
        controller.title = LocalizationManager.localizedString(key: "Conversation")
        localCommentReplyDidCreate = { comment in
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
            switch request {
            case _ as SPConversationRequest: self?.realTimeService?.refreshService()
                
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
        showWebPage(with: APIConstants.termsURLString)
    }

    internal func showPrivacy() {
        showWebPage(with: APIConstants.privacyURLString)
    }

    internal func showAddSpotIM() {
        showWebPage(with: APIConstants.joinURLString)
    }
    
    internal func viewHeightDidChange(to height: CGFloat) {
        self.spotLayoutDelegate?.viewHeightDidChange(to: height)
    }

}

extension SpotImSDKFlowCoordinator: UserAuthFlowDelegate {
    
    internal func signOut() {
        SPUserSessionHolder.resetUserSession()
        authHandlers.forEach { $0.value?.authHandler?(false) }
        sdkNavigationDelegate?.userDidBecomeUnauthorized()
    }
    
    internal func presentAuth() {
        if let controller = sdkNavigationDelegate?.controllerForSSOFlow() {
            controller.ssoAuthProvider.ssoAuthDelegate = self
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
        if shouldAddMain {
            insertMainConversationToNavigation(conversationModel)
        }
        localCommentReplyDidCreate?(comment)
    }

    internal func commentReplyDidBlock(with commentText: String?) {
        commentReplyCreationBlocked?(commentText)
    }
    
    @objc
    private func hidePresentedViewController() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension SpotImSDKFlowCoordinator: SSOAthenticationDelegate {
    
    public func ssoFlowDidSucceed() {
        hidePresentedViewController()
        authHandlers.forEach { $0.value?.authHandler?(true) }
    }
    
    public func ssoFlowDidFail(with error: Error?) {
        hidePresentedViewController()
    }
}
