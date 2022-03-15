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
    func presentControllerForSSOFlow(with spotNavController: UIViewController)
    func shouldDisplayLoginPromptForGuests() -> Bool
}

public enum CustomizableView {
    case loginPrompt(textView: UITextView)
    case communityQuestion(textView: UITextView)
    case sayControlInPreConversation(labelContainer: OWBaseView, label: OWBaseLabel)
    case sayControlInMainConversation(labelContainer: OWBaseView, label: OWBaseLabel)
    case conversationFooter(view: UIView)
    case communityGuidelines(textView: UITextView)
    case navigationItemTitle(textView: UITextView)
    case showCommentsButton(button: SPShowCommentsButton)
    case preConversationHeader(titleLabel: UILabel, counterLabel: UILabel)
    case commentCreationActionButton(button: OWBaseButton)
}

public protocol SpotImCustomUIDelegate: AnyObject {
    func customizeView(view: CustomizableView, isDarkMode: Bool)
}

internal protocol SPSafariWebPageDelegate: AnyObject {
    func openWebPage(with urlString: String)
}

public typealias SPShowFullConversationCompletionHandler = (_ success: Bool, _ error: SpotImError?) -> Void
public typealias SPOpenNewCommentCompletionHandler = (_ success: Bool, _ error: SpotImError?) -> Void

public enum SPViewControllerPresentationalMode {
    case present
    case push
}

// Default implementation - https://stackoverflow.com/questions/24032754/how-to-define-optional-methods-in-swift-protocol
public extension SpotImLoginDelegate {
    func presentControllerForSSOFlow(with spotNavController: UIViewController) {
        assertionFailure("If this method gets called it means you (the publisher) must override the default implementation for presentControllerForSSOFlow()")
    }
    
    func startLoginFlow() {
        assertionFailure("If this method gets called it means you (the publisher) must override the default implementation for startLoginFlow()")
    }
    func shouldDisplayLoginPromptForGuests() -> Bool {
        return false //default
    }
}

private class PresentedContainerNavigationController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let topViewController = topViewController {
            return topViewController.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
}

public let SPOTIM_NAV_CONTROL_TAG = 11223344;

final public class SpotImSDKFlowCoordinator: OWCoordinator {
    
    weak var containerViewController: UIViewController?
    
    static let USER_LOGIN_SUCCESS_NOTIFICATION = "USER_LOGIN_SUCCESS_NOTIFICATION"
    
    // MARK: - Services
    private lazy var commentsCacheService: SPCommentsInMemoryCacheService = .init()
    
    private let conversationUpdater: SPCommentUpdater
    
    private weak var sdkNavigationDelegate: SpotImSDKNavigationDelegate?
    private weak var spotLayoutDelegate: SpotImLayoutDelegate?
    private weak var loginDelegate: SpotImLoginDelegate?
    private weak var customUIDelegate: SpotImCustomUIDelegate?
    
    private var localCommentReplyDidCreate: ((SPComment) -> Void)?
    private var commentReplyCreationBlocked: ((String?) -> Void)?
    private var authHandlers: [WeakRef<OWAuthenticationHandler>] = []
    private var configCompletion: ((UIViewController) -> Void)?
    private var postId: String?
    private var shouldAddMain: Bool = false
    private weak var conversationModel: SPMainConversationModel?
    private let adsManager: AdsManager
    private let apiManager: OWApiManager
    private let imageProvider: SPImageProvider
    private weak var realTimeService: RealTimeService?
    private let spotConfig: SpotConfig
    private var isLoadingConversation: Bool = false
    private var preConversationViewController: UIViewController?
    private weak var authenticationViewDelegate: AuthenticationViewDelegate?
    
    ///If inputConfiguration parameter is nil Localization settings will be taken from server config
    internal init(spotConfig: SpotConfig, delegate: SpotImSDKNavigationDelegate, spotId: String, localeId: String?) {
        sdkNavigationDelegate = delegate
        adsManager = AdsManager(spotId: spotId)
        apiManager = OWApiManager()
        conversationUpdater = SPCommentFacade(apiManager: apiManager)
        self.spotConfig = spotConfig
        imageProvider = SPCloudinaryImageProvider(apiManager: apiManager)
        SPPermissionsProvider.delegate = self
        configureAPIAndRealTimeHandlers()
        
        if let localeId = localeId {
            LocalizationManager.setLocale(localeId)
        }
    }
    
    internal init(spotConfig: SpotConfig, loginDelegate: SpotImLoginDelegate, spotId: String, localeId: String?) {
        self.loginDelegate = loginDelegate
        adsManager = AdsManager(spotId: spotId)
        apiManager = OWApiManager()
        conversationUpdater = SPCommentFacade(apiManager: apiManager)
        self.spotConfig = spotConfig
        imageProvider = SPCloudinaryImageProvider(apiManager: apiManager)
        SPPermissionsProvider.delegate = self
        configureAPIAndRealTimeHandlers()
        
        if let localeId = localeId {
            LocalizationManager.setLocale(localeId)
        }
    }
    
    public func setLayoutDelegate(delegate: SpotImLayoutDelegate) {
        self.spotLayoutDelegate = delegate
    }
    
    public func setCustomUIDelegate(delegate: SpotImCustomUIDelegate) {
        self.customUIDelegate = delegate
    }
    
    /// Please, provide container (UINavigationViewController) for sdk flows
    public func preConversationController(withPostId postId: String,
                                          articleMetadata: SpotImArticleMetadata,
                                          numberOfPreLoadedMessages: Int = 2,
                                          navigationController: UINavigationController,
                                          completion: @escaping (UIViewController) -> Void)
    {
        let encodedPostId = encodePostId(postId: postId)
        containerViewController = navigationController
        let conversationModel = self.setupConversationDataProviderAndServices(postId: encodedPostId, articleMetadata: articleMetadata)
        self.conversationModel = conversationModel
        buildPreConversationController(with: conversationModel, numberOfPreLoadedMessages: numberOfPreLoadedMessages, completion: completion)
    }
    
    public func openFullConversationViewController(navigationController: UINavigationController, withPostId postId: String, articleMetadata: SpotImArticleMetadata, presentationalMode: SPViewControllerPresentationalMode = .push, selectedCommentId: String? = nil, completion: SPShowFullConversationCompletionHandler? = nil) {
        switch presentationalMode {
        case .present:
            presentFullConversationViewController(inViewController: navigationController, withPostId: postId, articleMetadata: articleMetadata, selectedCommentId: selectedCommentId, completion: completion)
        case .push:
            pushFullConversationViewController(navigationController: navigationController, withPostId: postId, articleMetadata: articleMetadata, selectedCommentId: selectedCommentId, completion: completion)
        }
    }
    
    public func openNewCommentViewController(navigationController: UINavigationController, withPostId postId: String, articleMetadata: SpotImArticleMetadata, fullConversationPresentationalMode: SPViewControllerPresentationalMode = .push, completion: SPOpenNewCommentCompletionHandler? = nil) {
        switch fullConversationPresentationalMode {
        case .present:
            // create nav controller in code to be the container for conversationController
            let navController = createNavController()
            self.prepareAndLoadConversation(containerViewController: navController, withPostId: postId, articleMetadata: articleMetadata) { result in
                switch result {
                case .success( _):
                    self.presentConversationInternal(presentationalController: navigationController, internalNavController: navController, selectedCommentId: nil, animated: true)
                    self.createComment(with: self.conversationModel!)
                    completion?(true, nil)
                case .failure(let spNetworkError):
                    print("spNetworkError: \(spNetworkError.localizedDescription)")
                    completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                    self.presentFailureAlert(viewController: navigationController, spNetworkError: spNetworkError) { _ in
                        self.openNewCommentViewController(navigationController: navigationController, withPostId: postId, articleMetadata: articleMetadata, fullConversationPresentationalMode: fullConversationPresentationalMode, completion: completion)
                    }
                    break
                }
            }
            break
        case .push:
            prepareAndLoadConversation(containerViewController: navigationController, withPostId: postId, articleMetadata: articleMetadata) { result in
                switch result {
                case .success( _):
                    self.showConversationInternal(selectedCommentId: nil, animated: false)
                    self.createComment(with: self.conversationModel!)
                    completion?(true, nil)
                case .failure(let spNetworkError):
                    print("spNetworkError: \(spNetworkError.localizedDescription)")
                    completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                    self.presentFailureAlert(viewController: navigationController, spNetworkError: spNetworkError) { _ in
                        self.openNewCommentViewController(navigationController: navigationController, withPostId: postId, articleMetadata: articleMetadata, fullConversationPresentationalMode: fullConversationPresentationalMode, completion: completion)
                    }
                    break
                }
            }
        }
    }
    
    // DEPRECATED - please use `openFullConversationViewController` instead
    public func pushFullConversationViewController(navigationController: UINavigationController, withPostId postId: String, articleMetadata: SpotImArticleMetadata, completion: SPShowFullConversationCompletionHandler? = nil) {
        pushFullConversationViewController(navigationController: navigationController, withPostId: postId, articleMetadata: articleMetadata, selectedCommentId: nil, completion: completion)
    }
    
    // DEPRECATED - please use `openFullConversationViewController` instead
    public func pushFullConversationViewController(navigationController: UINavigationController, withPostId postId: String, articleMetadata: SpotImArticleMetadata, selectedCommentId: String?, completion: SPShowFullConversationCompletionHandler? = nil)
    {
        self.prepareAndLoadConversation(containerViewController: navigationController, withPostId: postId, articleMetadata: articleMetadata) { result in
            switch result {
            case .success( _):
                self.showConversationInternal(selectedCommentId: selectedCommentId, animated: true)
                completion?(true, nil)
            case .failure(let spNetworkError):
                print("spNetworkError: \(spNetworkError.localizedDescription)")
                self.presentFailureAlert(viewController: navigationController, spNetworkError: spNetworkError) { _ in
                    self.pushFullConversationViewController(navigationController: navigationController, withPostId: postId, articleMetadata: articleMetadata, selectedCommentId: selectedCommentId)
                }
                completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                break
            }
        }
    }
    
    // DEPRECATED - please use `openFullConversationViewController` instead
    public func presentFullConversationViewController(inViewController viewController: UIViewController, withPostId postId: String, articleMetadata: SpotImArticleMetadata, selectedCommentId: String?, completion: SPShowFullConversationCompletionHandler? = nil) {
        
        // create nav controller in code to be the container for conversationController
        let navController = createNavController()
        self.prepareAndLoadConversation(containerViewController: navController, withPostId: postId, articleMetadata: articleMetadata) { result in
            switch result {
            case .success( _):
                self.presentConversationInternal(presentationalController: viewController, internalNavController: navController, selectedCommentId: selectedCommentId, animated: true)
                completion?(true, nil)
            case .failure(let spNetworkError):
                print("spNetworkError: \(spNetworkError.localizedDescription)")
                self.presentFailureAlert(viewController: viewController, spNetworkError: spNetworkError) { _ in
                    self.presentFullConversationViewController(inViewController: viewController, withPostId: postId, articleMetadata: articleMetadata, selectedCommentId: selectedCommentId)
                }
                completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                break
            }
        }
    }
    
    private func prepareAndLoadConversation(containerViewController: UIViewController?, withPostId postId: String, articleMetadata: SpotImArticleMetadata, completion: @escaping (Swift.Result<Bool, SPNetworkError>) -> Void) {
        guard !self.isLoadingConversation else { return }
        let encodedPostId = encodePostId(postId: postId)
        self.containerViewController = containerViewController
        let conversationModel = self.setupConversationDataProviderAndServices(postId: encodedPostId, articleMetadata: articleMetadata)
        self.conversationModel = conversationModel
        self.loadConversation(model: conversationModel, completion: completion)
    }
    
    private func showConversationInternal(selectedCommentId: String?, animated: Bool) {
        let controller = conversationController(with: self.conversationModel!, openedByPublisher: true)
        controller.commentIdToShowOnOpen = selectedCommentId
        conversationModel!.dataSource.showReplies = true
        startFlow(with: controller, animated: animated)
    }
    
    private func presentConversationInternal(presentationalController: UIViewController, internalNavController: UINavigationController,  selectedCommentId: String?, animated: Bool) {
        let conversationController = conversationController(with: conversationModel!, openedByPublisher: true)
        conversationController.commentIdToShowOnOpen = selectedCommentId
        self.conversationModel!.dataSource.showReplies = true
        
        // back button
        let backBarButtonItem = self.createBackBarButtonItem()
        conversationController.navigationItem.leftBarButtonItem = backBarButtonItem
        
        internalNavController.viewControllers = [conversationController]
        presentationalController.present(internalNavController, animated: animated)
    }
    
    private func createBackBarButtonItem() -> UIBarButtonItem {
        let backButton = UIButton(type: .custom)
        backButton.frame.size = CGSize(width: 44,height: 44) // set button size to enlarge hit area
        backButton.setTitleColor(.brandColor, for: .normal) // You can change the TitleColor
        backButton.setImage(UIImage(spNamed: "backButton", supportDarkMode: true), for: .normal) // Image can be downloaded from here below link
        backButton.contentHorizontalAlignment = .left
        backButton.addTarget(self, action: #selector(self.onClickCloseFullConversation(_:)), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func createNavController() -> UINavigationController {
        let navController = PresentedContainerNavigationController()
        navController.view.tag = SPOTIM_NAV_CONTROL_TAG
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.barTintColor = .spBackground0
        navController.navigationBar.backgroundColor = .spBackground0
        return navController
    }
    
    @IBAction func onClickCloseFullConversation(_ sender: UIButton) {
        self.closeMainConversation()
    }
    
    private func presentFailureAlert(viewController: UIViewController, spNetworkError:SPNetworkError, retryHandler: @escaping (UIAlertAction) -> Void) {
        let retryAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Retry"),
            style: .default,
            handler: retryHandler)
        
        let okAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "OK"),
            style: .default)
        
        let alert = UIAlertController(
            title: LocalizationManager.localizedString(key: "Oops..."),
            message: spNetworkError.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(retryAction)
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func setupConversationDataProviderAndServices(postId: String, articleMetadata: SpotImArticleMetadata) -> SPMainConversationModel {
        SPAnalyticsHolder.default.prepareForNewPage(customBIData: articleMetadata.customBIData)
        
        let conversationDataProvider = SPConversationsFacade(apiManager: apiManager)
        let conversationDataSource = SPMainConversationDataSource(
            with: postId,
            articleMetadata: articleMetadata,
            dataProvider: conversationDataProvider
        )
        conversationDataProvider.imageURLProvider = imageProvider
        let realTimeService = RealTimeService(realTimeDataProvider: DefaultRealtimeDataProvider(apiManager: apiManager))
        let conversationModel = SPMainConversationModel(
            commentUpdater: conversationUpdater,
            conversationDataSource: conversationDataSource,
            imageProvider: imageProvider,
            realTimeService: realTimeService,
            abTestData: spotConfig.abConfig
        )
        
        realTimeService.delegate = conversationModel
        self.realTimeService = realTimeService
        return conversationModel
    }
    
    private func loadConversation(model:SPMainConversationModel, completion: @escaping (Swift.Result<Bool, SPNetworkError>) -> Void) {
        guard !model.dataSource.isLoading else { return }
        
        let sortModeRaw = SPConfigsDataSource.appConfig?.initialization?.sortBy ?? SPCommentSortMode.initial.backEndTitle
        let sortMode = SPCommentSortMode(rawValue: sortModeRaw) ?? .initial
        self.isLoadingConversation = true
        model.dataSource.conversation(
            sortMode,
            page: .first,
            loadingStarted: {},
            completion: { (success, error) in
                self.isLoadingConversation = false
                if let error = error {
                    completion(.failure(error))
                } else if success == false {
                    completion(.failure(SPNetworkError.requestFailed))
                    OWLogger.error("Load conversation request type is not `success`")
                } else {
                    
                    let messageCount = model.dataSource.messageCount
                    SPAnalyticsHolder.default.totalComments = messageCount
                    SPAnalyticsHolder.default.log(event: .loaded, source: .conversation)
                    completion(.success(true))
                }
            }
        )
    }
    
    private func encodePostId(postId: String) -> String {
        let result = postId.replacingOccurrences(of: "urn:uri:base64:", with: "urn$3Auri$3Abase64$3A")
            .replacingOccurrences(of: ",", with: ";")
            .replacingOccurrences(of: "_", with: "$")
            .replacingOccurrences(of: ":", with: "~")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "/", with: "$2F")
        return result
    }
    
    private func startFlow(with controller: SPMainConversationViewController, animated: Bool = true) {
        navigationController?.pushViewController(controller, animated: animated)
    }
    
    private func buildPreConversationController(with conversationModel: SPMainConversationModel, numberOfPreLoadedMessages: Int, completion: @escaping (UIViewController) -> Void) {
        
        let preConversationViewController = SPPreConversationViewController(model: conversationModel, numberOfMessagesToShow: numberOfPreLoadedMessages, adsProvider: adsManager.adsProvider(), customUIDelegate: self)
        
        conversationModel.delegates.add(delegate: preConversationViewController)
        conversationModel.commentsCounterDelegates.add(delegate: preConversationViewController)
        
        preConversationViewController.delegate = self
        preConversationViewController.userAuthFlowDelegate = self
        
        preConversationViewController.preConversationDelegate = self
        preConversationViewController.webPageDelegate = self
        preConversationViewController.dataLoaded = { [weak self] in
            guard let preConversationViewController = self?.preConversationViewController else { return }
            
            self?.preConversationViewController = nil
            completion(preConversationViewController)
        }
        
        authHandlers.append(WeakRef(value: preConversationViewController.userDidSignInHandler()))
        
        self.preConversationViewController = preConversationViewController
    }
    
    private func conversationController(with model: SPMainConversationModel, openedByPublisher: Bool = false) -> SPMainConversationViewController {
        let controller = SPMainConversationViewController(model: model, adsProvider: adsManager.adsProvider(), customUIDelegate: self, openedByPublisher: openedByPublisher)
        
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        controller.webPageDelegate = self
        
        let navigationItemTitleText = LocalizationManager.localizedString(key: "Conversation")
        if SpotIm.enableCustomNavigationItemTitle {
            let navigationItemTextView = getNavigationItemTitleTextView(with: navigationItemTitleText)
            controller.navigationItem.titleView = navigationItemTextView
        } else {
            controller.title = navigationItemTitleText
        }
        
        OWLogger.verbose("FirstComment: localCommentReplayDidCreate SET")
        localCommentReplyDidCreate = { comment in
            OWLogger.verbose("FirstComment: localCommentReplayDidCreate CALLED")
            OWLogger.verbose("FirstComment: setting the pending comment to the model")
            model.pendingComment = comment
        }
        commentReplyCreationBlocked = { commentText in
            model.handleMessageCreationBlockage(with: commentText)
        }
        
        authHandlers.append(WeakRef(value: controller.userDidSignInHandler()))
        return controller
    }
    
    private func getNavigationItemTitleTextView(with text: String) -> UITextView {
        let navigationItemTextView = UITextView()
        navigationItemTextView.backgroundColor = UIColor.clear
        let attributedTitleText = NSMutableAttributedString(string: text)
        attributedTitleText.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .regular), range: NSMakeRange(0, attributedTitleText.length))
        navigationItemTextView.attributedText = attributedTitleText
        navigationItemTextView.isEditable = false
        navigationItemTextView.isSelectable = false
        customizeNavigationItemTitle(textView: navigationItemTextView)
        return navigationItemTextView
    }
    
    private func presentContentCreationViewController(controller: SPCommentCreationViewController, _ dataModel: SPMainConversationModel) {
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
            case _ as SPConversationRequest: strongSelf.realTimeService?.refreshService()
                
            default: break
            }
        }
    }
}

extension SpotImSDKFlowCoordinator: SPSafariWebPageDelegate {
    func openWebPage(with urlString: String) {
        showWebPage(with: urlString)
    }
}

extension SpotImSDKFlowCoordinator: SPCommentsCreationDelegate {
    
    internal func createComment(with dataModel: SPMainConversationModel) {
        
        let model = getCommentCreationModel(with: dataModel.dataSource.commentCreationModel(),
                                            articleMetadata: dataModel.dataSource.articleMetadata)
        setupAndPresentCommentCreation(with: model, dataModel: dataModel)
    }
    
    internal func createReply(with dataModel: SPMainConversationModel, to id: String) {
        
        let model = getCommentCreationModel(with: dataModel.dataSource.replyCreationModel(for: id),
                                            articleMetadata: dataModel.dataSource.articleMetadata)
        
        setupAndPresentCommentCreation(with: model, dataModel: dataModel)
    }
    
    internal func editComment(with dataModel: SPMainConversationModel,
                              to id: String) {
        
        let model = getCommentCreationModel(with: dataModel.dataSource.editCommentModel(for: id),
                                            articleMetadata: dataModel.dataSource.articleMetadata)
        
        setupAndPresentCommentCreation(with: model, dataModel: dataModel)
    }
    
    internal func setupAndPresentCommentCreation(with model: SPCommentCreationModel,
                                                 dataModel: SPMainConversationModel) {
        
        let controller = SPCommentCreationViewController(customUIDelegate: self, model: model)
        controller.delegate = self
        controller.userAuthFlowDelegate = self
        dataModel.dataSource.showReplies = true
        presentContentCreationViewController(controller: controller, dataModel)
    }
    
    internal func getCommentCreationModel(with dto: SPCommentCreationDTO, articleMetadata : SpotImArticleMetadata) -> SPCommentCreationModel {
        return SPCommentCreationModel(
            commentCreationDTO: dto,
            cacheService: commentsCacheService,
            updater: conversationUpdater,
            imageProvider: imageProvider,
            articleMetadate: articleMetadata
        )
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
        let urlString = spotConfig.appConfig.mobileSdk.openwebTermsUrl
        showWebPage(with: urlString)
    }
    
    internal func showPrivacy() {
        let urlString = spotConfig.appConfig.mobileSdk.openwebPrivacyUrl
        showWebPage(with: urlString)
    }
    
    internal func showAddSpotIM() {
        let urlString = spotConfig.appConfig.mobileSdk.openwebWebsiteUrl
        showWebPage(with: urlString)
    }
    
    internal func viewHeightDidChange(to height: CGFloat) {
        self.spotLayoutDelegate?.viewHeightDidChange(to: height)
    }
    
}

extension SpotImSDKFlowCoordinator: OWUserAuthFlowDelegate {
    internal func presentAuth() {
        SpotIm.authProvider.ssoAuthDelegate = self
        if let loginDelegate = self.loginDelegate {
            if self.navigationController?.view.tag == SPOTIM_NAV_CONTROL_TAG {
                loginDelegate.presentControllerForSSOFlow(with: self.navigationController!)
            }
            else {
                loginDelegate.startLoginFlow()
            }
        } else if let controller = sdkNavigationDelegate?.controllerForSSOFlow() {
            // Deprecated - this code should be removed once the deprecated sdkNavigationDelegate is deleted from the SDK
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
    
    func shouldDisplayLoginPromptForGuests() -> Bool {
        if let loginDelegate = self.loginDelegate {
            return loginDelegate.shouldDisplayLoginPromptForGuests()
        }
        return false
    }
}

extension SpotImSDKFlowCoordinator: CommentReplyViewControllerDelegate {
    
    internal func commentReplyDidCreate(_ comment: SPComment) {
        OWLogger.verbose("FirstComment: Did received comment in delegate")
        if let model = conversationModel, shouldAddMain {
            OWLogger.verbose("FirstComment: Adding main conversation screen before we continue")
            insertMainConversationToNavigation(model)
        }
        localCommentReplyDidCreate?(comment)
    }
    
    internal func commentReplyDidBlock(with commentText: String?) {
        commentReplyCreationBlocked?(commentText)
    }
    
    internal func commentReplyDidEdit(with comment: SPComment) {
        conversationModel?.handleEditedComment(comment: comment)
    }
    
    @objc
    private func hidePresentedViewController() {
        if self.sdkNavigationDelegate != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
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
        NotificationCenter.default.post(name: Notification.Name(SpotImSDKFlowCoordinator.USER_LOGIN_SUCCESS_NOTIFICATION), object: nil)
    }
    
    public func ssoFlowDidFail(with error: Error?) {
        hidePresentedViewController()
    }
    
    public func userLogout() {
        authHandlers.forEach { $0.value?.authHandler?(false) }
    }
}

extension SpotImSDKFlowCoordinator: OWCustomUIDelegate {
    func customizeShowCommentsButton(button: SPShowCommentsButton) {
        customUIDelegate?.customizeView(view: .showCommentsButton(button: button), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    
    func customizeLoginPromptTextView(textView: UITextView) {
        customUIDelegate?.customizeView(view: .loginPrompt(textView: textView), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    func customizeCommunityQuestionTextView(textView: UITextView) {
        customUIDelegate?.customizeView(view: .communityQuestion(textView: textView), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    func customizeSayControl(labelContainer: OWBaseView, label: OWBaseLabel, isPreConversation: Bool) {
        let view: CustomizableView = isPreConversation ? .sayControlInPreConversation(labelContainer: labelContainer, label: label) : .sayControlInMainConversation(labelContainer: labelContainer, label: label)
        customUIDelegate?.customizeView(view: view, isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    func customizeConversationFooter(view: UIView) {
        customUIDelegate?.customizeView(view: .conversationFooter(view: view), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    func customizeCommunityGuidelines(textView: UITextView) {
        customUIDelegate?.customizeView(view: .communityGuidelines(textView: textView), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    func customizeNavigationItemTitle(textView: UITextView) {
        guard SpotIm.enableCustomNavigationItemTitle else { return }
        customUIDelegate?.customizeView(view: .navigationItemTitle(textView: textView), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
    
    func customizePreConversationHeader(titleLabel: UILabel, counterLabel: UILabel) {
        customUIDelegate?.customizeView(view: .preConversationHeader(titleLabel: titleLabel, counterLabel: counterLabel), isDarkMode:  SPUserInterfaceStyle.isDarkMode)
    }
    func customizeCommentCreationActionButton(button: OWBaseButton) {
        customUIDelegate?.customizeView(view: .commentCreationActionButton(button: button), isDarkMode: SPUserInterfaceStyle.isDarkMode)
    }
}

extension SpotImSDKFlowCoordinator: SPPermissionsProviderDelegate {
    func presentAlert(_ alert: UIAlertController) {
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
