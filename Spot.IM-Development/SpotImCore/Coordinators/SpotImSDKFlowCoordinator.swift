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
import RxSwift

public protocol SpotImLayoutDelegate: AnyObject {
    func viewHeightDidChange(to newValue: CGFloat)
}

public protocol AuthenticationViewDelegate: AnyObject {
    func authenticationStarted()
}

public protocol SpotImLoginDelegate: AnyObject {
    func startLoginUIFlow(navigationController: UINavigationController)
    func renewSSOAuthentication(userId: String)
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
    case readOnlyLabel(label: UILabel)
    case emptyStateReadOnlyLabel(label: UILabel)
}

public protocol SpotImCustomUIDelegate: AnyObject {
    func customizeView(view: CustomizableView, isDarkMode: Bool, postId: String)
}

internal protocol SPSafariWebPageDelegate: AnyObject {
    func openWebPage(with urlString: String)
}

public typealias SPShowFullConversationCompletionHandler = (_ success: Bool, _ error: SpotImError?) -> Void
public typealias SPOpenNewCommentCompletionHandler = (_ success: Bool, _ error: SpotImError?) -> Void

public enum SPViewControllerPresentationalMode {
    case present(viewController: UIViewController)
    case push(navigationController: UINavigationController)
}

// Default implementation - https://stackoverflow.com/questions/24032754/how-to-define-optional-methods-in-swift-protocol
public extension SpotImLoginDelegate {
    func startLoginUIFlow(navigationController: UINavigationController) {
        assertionFailure("If this method gets called it means you (the publisher) must override the default implementation for startLoginUIFlow(navigationController:)")
    }
    func renewSSOAuthentication(userId: String) {
        assertionFailure("If this method gets called it means you (the publisher) must override the default implementation for renewSSOAuthentication(userId:)")
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
    private let conversationUpdater: SPCommentUpdater
    
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
    
    private var viewActionsCallback: SPViewActionsCallbacks?
    private var mainConversationModelDisposeBag = DisposeBag()
    private var createCommentDisposeBag = DisposeBag()
    
    fileprivate let servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
    
    // The creation of this service alone is enough to begin the renew process in case the "Authorization" header token expired
    // Everything happen in the init, so it's ok this variable is not being used.
    // Solving auth expiration after application was in background for some days (or the lifespan of the token)
    fileprivate let authenticationRenewerService: OWAuthenticationRenewerServicing = OWAuthenticationRenewerService()
    
    ///If inputConfiguration parameter is nil Localization settings will be taken from server config
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
        
        // Set self to be the delegate for all auth provider functions
        SpotIm.authProvider.ssoAuthDelegate = self
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
                                          callbacks: SPViewActionsCallbacks? = nil,
                                          completion: @escaping (UIViewController) -> Void)
    {
        self.viewActionsCallback = callbacks
        self.postId = (postId as OWPostId).encoded
        containerViewController = navigationController
        if let conversationModel = self.setupConversationDataProviderAndServices( articleMetadata: articleMetadata) {
            self.setupObservers(for: conversationModel)
            self.conversationModel = conversationModel
            buildPreConversationController(with: conversationModel, numberOfPreLoadedMessages: numberOfPreLoadedMessages, completion: completion)
        }
    }
    
    public func openFullConversationViewController(postId: String, articleMetadata: SpotImArticleMetadata, presentationalMode: SPViewControllerPresentationalMode, selectedCommentId: String? = nil, callbacks: SPViewActionsCallbacks? = nil, completion: SPShowFullConversationCompletionHandler? = nil) {
        
        let navController: UINavigationController
        switch presentationalMode {
        case .present(_):
            // Create nav controller in code to be the container for conversationController
            navController = createNavController()
        case .push(let navigationController):
            navController = navigationController
        }
        
        self.viewActionsCallback = callbacks
        self.prepareAndLoadConversation(containerViewController: navController, withPostId: postId, articleMetadata: articleMetadata) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success( _):
                switch presentationalMode {
                case .present(let viewController):
                    self.presentConversationInternal(presentationalController: viewController, internalNavController: navController, selectedCommentId: selectedCommentId, animated: true)
                case .push(_):
                    self.showConversationInternal(selectedCommentId: selectedCommentId, animated: true)
                }
                completion?(true, nil)
            case .failure(let spNetworkError):
                let vcToPresentError: UIViewController
                switch presentationalMode {
                case .present(let viewController):
                    vcToPresentError = viewController
                case .push(let navigationController):
                    vcToPresentError = navigationController
                }
                self.servicesProvider.logger().log(level: .error, "spNetworkError: \(spNetworkError.localizedDescription)")
                self.presentFailureAlert(viewController: vcToPresentError, spNetworkError: spNetworkError) { _ in
                    // Retry
                    self.openFullConversationViewController(postId: postId, articleMetadata: articleMetadata, presentationalMode: presentationalMode, selectedCommentId: selectedCommentId, callbacks: callbacks, completion: completion)
                }
                completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                break
            }
        }
    }
    
    public func openNewCommentViewController(postId: String, articleMetadata: SpotImArticleMetadata, fullConversationPresentationalMode: SPViewControllerPresentationalMode, callbacks: SPViewActionsCallbacks? = nil, completion: SPOpenNewCommentCompletionHandler? = nil) {
        self.viewActionsCallback = callbacks
        switch fullConversationPresentationalMode {
        case .present(let viewController):
            // create nav controller in code to be the container for conversationController
            let navController = createNavController()
            self.prepareAndLoadConversation(containerViewController: navController, withPostId: postId, articleMetadata: articleMetadata) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success( _):
                    self.presentConversationInternal(presentationalController: viewController, internalNavController: navController, selectedCommentId: nil, animated: true)
                    
                    let model = self.conversationModel!
                    if (!model.isReadOnlyMode()) {
                        self.createComment(with: model)
                    }
                    completion?(true, nil)
                case .failure(let spNetworkError):
                    self.servicesProvider.logger().log(level: .error, "spNetworkError: \(spNetworkError.localizedDescription)")
                    completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                    self.presentFailureAlert(viewController: viewController, spNetworkError: spNetworkError) { _ in
                        self.openNewCommentViewController(postId: postId, articleMetadata: articleMetadata, fullConversationPresentationalMode: fullConversationPresentationalMode, completion: completion)
                    }
                    break
                }
            }
            break
        case .push(let navigationController):
            prepareAndLoadConversation(containerViewController: navigationController, withPostId: postId, articleMetadata: articleMetadata) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success( _):
                    let model = self.conversationModel!
                    let shouldAnimateConversation = model.isReadOnlyMode() ? true : false
                    self.showConversationInternal(selectedCommentId: nil, animated: shouldAnimateConversation)
                    
                    if (!model.isReadOnlyMode()) {
                        self.createComment(with: model)
                    }
                    completion?(true, nil)
                case .failure(let spNetworkError):
                    self.servicesProvider.logger().log(level: .error, "spNetworkError: \(spNetworkError.localizedDescription)")
                    completion?(false, SpotImError.internalError(spNetworkError.localizedDescription))
                    self.presentFailureAlert(viewController: navigationController, spNetworkError: spNetworkError) { _ in
                        self.openNewCommentViewController(postId: postId, articleMetadata: articleMetadata, fullConversationPresentationalMode: fullConversationPresentationalMode, completion: completion)
                    }
                    break
                }
            }
        }
    }
    
    private func prepareAndLoadConversation(containerViewController: UIViewController?, withPostId postId: String, articleMetadata: SpotImArticleMetadata, completion: @escaping (Swift.Result<Bool, SPNetworkError>) -> Void) {
        guard !self.isLoadingConversation else { return }
        self.postId = (postId as OWPostId).encoded
        self.containerViewController = containerViewController
        if let conversationModel = self.setupConversationDataProviderAndServices( articleMetadata: articleMetadata) {
            self.setupObservers(for: conversationModel)
            self.conversationModel = conversationModel
            self.loadConversation(model: conversationModel, completion: completion)
        }
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
    
    @IBAction func onClickCloseFullConversation(_ sender: UIBarButtonItem) {
        containerViewController?.dismiss(animated: true, completion: nil)
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
    
    private func setupConversationDataProviderAndServices(articleMetadata: SpotImArticleMetadata) -> SPMainConversationModel? {
        guard let postId = postId else { return nil }

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
        
        conversationDataSource.conversationModel = conversationModel
        
        realTimeService.delegate = conversationModel
        self.realTimeService = realTimeService
        return conversationModel
    }
    
    private func setupObservers(for model: SPMainConversationModel) {
        mainConversationModelDisposeBag = DisposeBag()
        model.actionCallback
            .subscribe( onNext: { [weak self] (type, source) in
                guard let self = self, let postId = self.postId else { return }
                self.viewActionsCallback?(type, source, postId)
            })
            .disposed(by: mainConversationModelDisposeBag)
    }
    
    private func setupObservers(for model: SPCommentCreationModel) {
        createCommentDisposeBag = DisposeBag()
        model.actionCallback
            .subscribe( onNext: { [weak self] type in
                guard let self = self, let postId = self.postId else { return }
                self.viewActionsCallback?(type, .createComment, postId)
            })
            .disposed(by: createCommentDisposeBag)
    }
    
    private func loadConversation(model:SPMainConversationModel, completion: @escaping (Swift.Result<Bool, SPNetworkError>) -> Void) {
        guard !model.dataSource.isLoading else { return }
        
        self.isLoadingConversation = true
        model.dataSource.conversation(
            model.getInitialSortMode(),
            page: .first,
            loadingStarted: {},
            completion: { [weak self] (success, error) in
                guard let self = self else { return }
                self.isLoadingConversation = false
                if let error = error {
                    completion(.failure(error))
                } else if success == false {
                    completion(.failure(SPNetworkError.requestFailed))
                    self.servicesProvider.logger().log(level: .error, "Load conversation request type is not `success`")
                } else {
                    
                    let messageCount = model.dataSource.messageCount
                    SPAnalyticsHolder.default.totalComments = messageCount
                    SPAnalyticsHolder.default.log(event: .loaded, source: .conversation)
                    completion(.success(true))
                }
            }
        )
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
        
        servicesProvider.logger().log(level: .verbose, "FirstComment: localCommentReplayDidCreate SET")

        localCommentReplyDidCreate = { [weak self] comment in
            guard let self = self else { return }
            self.servicesProvider.logger().log(level: .verbose, "FirstComment: localCommentReplayDidCreate CALLED")
            self.servicesProvider.logger().log(level: .verbose, "FirstComment: setting the pending comment to the model")
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
        navigationItemTextView.isScrollEnabled = false
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
        
        let logger =  servicesProvider.logger()
        
        // We should insert the main conversation below the comment creation screen
        guard let navController = navigationController,
              let commentVCIndex = navController.viewControllers.firstIndex(where: { $0 is SPCommentCreationViewController }) else {
                  logger.log(level: .medium, "Couldn't find comment creation VC index, recovering by inserting main conversation VC to the previous position before the last one in the navigation stack VCs")
                  let index = (navigationController?.viewControllers.count ?? 1) - 1
                  navigationController?.viewControllers.insert(controller, at: index)
                  return
              }
        
        logger.log(level: .verbose, "Inserting main conversation VC before the comment creation VC")
        navigationController?.viewControllers.insert(controller, at: commentVCIndex)
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

// Custom Navigation Conttoller
extension SpotImSDKFlowCoordinator {
    fileprivate struct Metrics {
        static let backBarButtonSize: CGFloat = 70.0
        static let backBarButtonImageInsetLeft: CGFloat = -6.0
        static let backBarButtonTitleInset: CGFloat = 10.0
        static let navigationTitleFontSize: CGFloat = 20.0
    }
    
    private func createBackBarButtonItem() -> UIBarButtonItem {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: Metrics.backBarButtonSize, height: Metrics.backBarButtonSize))
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: Metrics.backBarButtonImageInsetLeft, bottom: 0, right: 0)
        backButton.titleEdgeInsets = UIEdgeInsets(top: Metrics.backBarButtonTitleInset, left: Metrics.backBarButtonTitleInset, bottom: Metrics.backBarButtonTitleInset, right: 0.0)

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
        
        navController.navigationBar.tintColor = .black
        navController.navigationBar.barTintColor = .spBackground0
        navController.navigationBar.isTranslucent = false
        
        let navigationBarBackgroundColor = UIColor.spBackground0
        let navigationTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: Metrics.navigationTitleFontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = navigationBarBackgroundColor
            appearance.titleTextAttributes = navigationTitleTextAttributes

            navController.navigationBar.standardAppearance = appearance;
            navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
        } else {
            navController.navigationBar.backgroundColor = navigationBarBackgroundColor
            navController.navigationBar.titleTextAttributes = navigationTitleTextAttributes
        }
        
        return navController
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
        let model = SPCommentCreationModel(
            commentCreationDTO: dto,
            updater: conversationUpdater,
            imageProvider: imageProvider,
            articleMetadate: articleMetadata
        )
        self.setupObservers(for: model)
        return model
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
    func presentAuth() {
        if let loginDelegate = self.loginDelegate {
            if let tag = self.navigationController?.view.tag,
               tag == SPOTIM_NAV_CONTROL_TAG,
               let navController = self.navigationController{
                loginDelegate.startLoginUIFlow(navigationController: navController)
            } else {
                guard let navController = containerViewController as? UINavigationController else {
                    servicesProvider.logger().log(level: .error, "Supposed to call startLoginUIFlow but UINavigationController is missing")
                    return
                }
                loginDelegate.startLoginUIFlow(navigationController: navController)
            }
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
        servicesProvider.logger().log(level: .verbose, "FirstComment: Did received comment in delegate")
        if let model = conversationModel, shouldAddMain {
            servicesProvider.logger().log(level: .verbose, "FirstComment: Adding main conversation screen before we continue")
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
}

extension SpotImSDKFlowCoordinator: SSOAthenticationDelegate {
    func ssoFlowStarted() {
        authenticationViewDelegate?.authenticationStarted()
    }
    
    func ssoFlowDidSucceed() {
        authHandlers.forEach { $0.value?.authHandler?(true) }
        NotificationCenter.default.post(name: Notification.Name(SpotImSDKFlowCoordinator.USER_LOGIN_SUCCESS_NOTIFICATION), object: nil)
    }
    
    func ssoFlowDidFail(with error: Error?) {
        
    }
    
    func userLogout() {
        authHandlers.forEach { $0.value?.authHandler?(false) }
    }
    
    func renewSSO(userId: String) {
        loginDelegate?.renewSSOAuthentication(userId: userId)
    }
}

extension SpotImSDKFlowCoordinator: OWCustomUIDelegate {
    private func customizeView(_ view: CustomizableView) {
        guard let postId = self.postId else { return }
        customUIDelegate?.customizeView(view: view, isDarkMode: SPUserInterfaceStyle.isDarkMode, postId: postId)
    }
    
    func customizeShowCommentsButton(button: SPShowCommentsButton) {
        self.customizeView(.showCommentsButton(button: button))
    }
    
    func customizeLoginPromptTextView(textView: UITextView) {
        self.customizeView(.loginPrompt(textView: textView))
    }
    func customizeCommunityQuestionTextView(textView: UITextView) {
        self.customizeView(.communityQuestion(textView: textView))
    }
    func customizeSayControl(labelContainer: OWBaseView, label: OWBaseLabel, isPreConversation: Bool) {
        let view: CustomizableView = isPreConversation ? .sayControlInPreConversation(labelContainer: labelContainer, label: label) : .sayControlInMainConversation(labelContainer: labelContainer, label: label)
        
        self.customizeView(view)
    }
    func customizeConversationFooter(view: UIView) {
        self.customizeView(.conversationFooter(view: view))
    }
    func customizeCommunityGuidelines(textView: UITextView) {
        self.customizeView(.communityGuidelines(textView: textView))
    }
    func customizeNavigationItemTitle(textView: UITextView) {
        guard SpotIm.enableCustomNavigationItemTitle else { return }
        self.customizeView(.navigationItemTitle(textView: textView))
    }
    
    func customizePreConversationHeader(titleLabel: UILabel, counterLabel: UILabel) {
        self.customizeView(.preConversationHeader(titleLabel: titleLabel, counterLabel: counterLabel))
    }
    func customizeCommentCreationActionButton(button: OWBaseButton) {
        self.customizeView(.commentCreationActionButton(button: button))
    }
    
    func customizeReadOnlyLabel(label: UILabel) {
        self.customizeView(.readOnlyLabel(label: label))
    }
    func customizeEmptyStateReadOnlyLabel(label: UILabel) {
        self.customizeView(.emptyStateReadOnlyLabel(label: label))
    }
}

extension SpotImSDKFlowCoordinator: SPPermissionsProviderDelegate {
    func presentAlert(_ alert: UIAlertController) {
        navigationController?.present(alert, animated: true, completion: nil)
    }
}
