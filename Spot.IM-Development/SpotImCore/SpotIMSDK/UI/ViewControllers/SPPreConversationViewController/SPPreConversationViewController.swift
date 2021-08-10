//
//  SPPreConversationViewController.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 13/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPPreConversationViewController: SPBaseConversationViewController {

    private let PRE_LOADED_MESSAGES_MAX_NUM = 15
    
    let adsProvider: AdsProvider
    internal weak var preConversationDelegate: SPPreConversationViewControllerDelegate?

    private lazy var bannerView: PreConversationBannerView = .init()
    private lazy var communityQuestionView = SPCommunityQuestionView()
    private lazy var communityGuidelinesView: SPCommunityGuidelinesView = .init()
    private lazy var header: SPPreConversationHeaderView = .init()
    private lazy var whatYouThinkView: SPMainConversationFooterView = .init()
    private lazy var footerView: SPPreConversationFooter = .init()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?

    private var checkTableViewHeight: CGFloat = 0
    private let maxSectionCount: Int
    private let readingTracker = SPReadingTracker()
    private let visibilityTracker = ViewVisibilityTracker()
    private let bannerVisisilityTracker = ViewVisibilityTracker()
    private var didBecomeVisible: Bool = false
    private var isWaitingForSignIn: Bool = false
    private var communityGuidelinesHtmlString: String? = nil
    
    private var isButtonOnlyModeEnabled: Bool = false
    
    internal var dataLoaded: (() -> Void)?
    
    internal override var screenTargetType: SPAnScreenTargetType {
        return .preMain
    }

    internal override var messageLineLimit: Int { SPCommonConstants.commentTextLineLimitPreConv }

    private var actualBannerMargin: CGFloat {
        bannerView.frame.height == 0 ? 0 : Theme.bannerViewMargin
    }
    
    private var totalHeight: CGFloat {
        let result = bannerView.frame.height +
            actualBannerMargin +
            header.frame.height +
            communityGuidelinesView.frame.height +
            whatYouThinkView.frame.height +
            tableView.frame.height +
            footerView.frame.height +
            communityQuestionView.frame.height
        
        return result
    }

    deinit {
        self.readingTracker.stopReadingTracking()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Overrides
    internal init(model: SPMainConversationModel, numberOfMessagesToShow: Int, adsProvider: AdsProvider, customUIDelegate: CustomUIDelegate?) {
        
        self.adsProvider = adsProvider
        // when buttonOnlyMode is on, show no comments
        self.maxSectionCount = SpotIm.buttonOnlyMode.isEnabled() ? 0 :
                            (numberOfMessagesToShow < PRE_LOADED_MESSAGES_MAX_NUM ? numberOfMessagesToShow : PRE_LOADED_MESSAGES_MAX_NUM)
        // button only when numberOfMessagesToShow is 0 OR publisher set mode in SpotIm
        self.isButtonOnlyModeEnabled = (numberOfMessagesToShow == 0 || SpotIm.buttonOnlyMode.isEnabled())
        
        super.init(model: model, customUIDelegate: customUIDelegate)
        adsProvider.bannerDelegate = self
        adsProvider.interstitialDelegate = self
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(appMovedToBackground),
        name: UIApplication.willResignActiveNotification,
        object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(overrideUserInterfaceStyleDidChange),
            name: Notification.Name(SpotIm.OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION),
            object: nil)

        
        SPAnalyticsHolder.default.log(event: .loaded, source: .launcher)
        
        loadConversation()
        
        self.visibilityTracker.setup(view: view, delegate: self)
        self.bannerVisisilityTracker.setup(view: self.bannerView, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateWhatYouThinkView()
        
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.updateTableViewHeightIfNeeded()
        
        if self.model.areCommentsEmpty() {
            self.showEmptyStateView()
        } else {
            self.hideEmptyStateView()
            self.header.set(commentCount: self.model.dataSource.messageCount.decimalFormatted)
            self.footerView.set(commentsCount: self.model.dataSource.messageCount.decimalFormatted)
            self.stateActionView?.removeFromSuperview()
            self.stateActionView = nil
        }
        
        self.visibilityTracker.startTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.visibilityTracker.stopTracking()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard checkTableViewHeight != totalHeight else { return }
        checkTableViewHeight = totalHeight
        UIView.performWithoutAnimation {
            self.preConversationDelegate?.viewHeightDidChange(to: totalHeight)
        }
    }
    
    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        self.view.backgroundColor = .spBackground0
        self.tableView.backgroundColor = .spBackground0
        self.bannerView.updateColorsAccordingToStyle()
        self.whatYouThinkView.updateColorsAccordingToStyle()
        self.updateFooterViewCustomUI(footerView: self.whatYouThinkView)
        self.communityQuestionView.updateColorsAccordingToStyle()
        self.updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
        self.communityGuidelinesView.updateColorsAccordingToStyle()
        if let htmlString = self.communityGuidelinesHtmlString {
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
        }
        self.header.updateColorsAccordingToStyle()
        self.footerView.updateColorsAccordingToStyle()
    }
    
    override func updateFooterViewCustomUI(footerView: SPMainConversationFooterView, isPreConversation: Bool = false) {
        super.updateFooterViewCustomUI(footerView: footerView, isPreConversation: true)
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let state = UIApplication.shared.applicationState
        if #available(iOS 12.0, *) {
            if previousTraitCollection?.userInterfaceStyle != self.traitCollection.userInterfaceStyle {
                // traitCollectionDidChange() is called multiple times, see: https://stackoverflow.com/a/63380259/583425
                if state != .background {
                    self.tableView.reloadData()
                    self.updateColorsAccordingToStyle()
                }
            }
        } else {
            if state != .background {
                self.tableView.reloadData()
                self.updateColorsAccordingToStyle()
            }
        }
    }

    private func updateTableViewHeightIfNeeded() {
        guard let heightConstraint = tableViewHeightConstraint,
            heightConstraint.constant != tableView.contentSize.height
            else { return }

        tableViewHeightConstraint?.constant = tableView.contentSize.height
        view.layoutIfNeeded()
    }
    
    // MARK: - Private methods

    override func setupUI() {
        view.addSubviews(bannerView, header, communityGuidelinesView, communityQuestionView, whatYouThinkView, footerView)

        super.setupUI()

        setupBannerView()
        setupHeader()
        configureCommunityQuestionView()
        setupCommunityGuidelinesView()
        setupWhatYouThinkView()
        setupFooterView()

        footerView.setShowMoreCommentsButtonColor(color: .brandColor, withSeparator: true)
    }
    
    private func setupBannerView() {
        bannerView.layout {
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.top.equal(to: view.topAnchor)
        }
    }

    private func setupHeader() {
        header.set(title: LocalizationManager.localizedString(key: "Conversation"))

        header.layout {
            $0.top.equal(to: bannerView.bottomAnchor, offsetBy: actualBannerMargin)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: SpotIm.buttonOnlyMode == .withoutTitle ? 0 : Theme.headerHeight)
        }
        
        if SpotIm.buttonOnlyMode == .withoutTitle {
            header.isHidden = true
        }
    }
    
    private func configureCommunityQuestionView() {
        communityQuestionView.clipsToBounds = true
        updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
        communityQuestionView.layout {
            $0.top.equal(to: communityGuidelinesView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
    }
    
    private func updateCommunityQuestion(communityQuestionText: String?) {
        // hide when no community question or in on button mode
        if let communityQuestionText = communityQuestionText, communityQuestionText.length > 0, !isButtonOnlyModeEnabled {
            communityQuestionView.setCommunityQuestionText(question: communityQuestionText)
            communityQuestionView.clipsToBounds = true
            communityQuestionView.setupPreConversationConstraints()
            communityGuidelinesView.setSeperatorVisible(isVisible: false)
        } else {
            communityQuestionView.isHidden = true
            communityQuestionView.layout {
                $0.height.equal(to: 0.0)
            }
            communityGuidelinesView.setSeperatorVisible(isVisible: true)
        }
        updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
    }
    
    private func setupCommunityGuidelinesView() {
        communityGuidelinesView.layout {
            $0.top.equal(to: header.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        // hide when no community guidelines or in button only mode
        if let htmlString = getCommunityGuidelinesTextIfExists(), !isButtonOnlyModeEnabled {
            communityGuidelinesHtmlString = htmlString
            communityGuidelinesView.delegate = self
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
            communityGuidelinesView.setupPreConversationConstraints()
        } else {
            communityGuidelinesView.isHidden = true
            communityGuidelinesView.layout {
                $0.height.equal(to: 0.0)
            }
        }
    }

    private func setupWhatYouThinkView() {
        view.bringSubviewToFront(whatYouThinkView)
        whatYouThinkView.updateOnlineStatus(.online)
        whatYouThinkView.dropsShadow = false
        whatYouThinkView.showsSeparator = false
        whatYouThinkView.delegate = self
        whatYouThinkView.layout {
            $0.top.equal(to: communityQuestionView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: Theme.whatYouThinkHeight)
        }
        self.updateFooterViewCustomUI(footerView: self.whatYouThinkView)
    }
    
    override func setupTableView() {
        super.setupTableView()

        tableView.isScrollEnabled = false
        tableView.layout {
            $0.top.equal(to: whatYouThinkView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            tableViewHeightConstraint = $0.height.equal(to: 0)
        }
    }

    private func setupFooterView() {
        view.bringSubviewToFront(footerView)
        footerView.delegate = self
        footerView.set(buttonOnlyMode: isButtonOnlyModeEnabled)
        footerView.layout {
            $0.top.equal(to: tableView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
    }

    private func loadConversation() {
        guard !model.dataSource.isLoading else { return }

        let sortModeRaw = SPConfigsDataSource.appConfig?.initialization?.sortBy ?? SPCommentSortMode.initial.backEndTitle
        let sortMode = SPCommentSortMode(rawValue: sortModeRaw) ?? .initial
        model.dataSource.conversation(
            sortMode,
            page: .first,
            loadingStarted: {},
            completion: { (success, error) in
                if let error = error {
                    if self.model.areCommentsEmpty() {
                        self.presentErrorView(error: error)
                    } else {
                        self.showAlert(
                            title: LocalizationManager.localizedString(key: "Oops..."),
                            message: error.localizedDescription
                        )
                    }
                } else if success == false {
                    Logger.error("Load conversation request type is not `success`")
                } else {
                    self.checkAdsAvailability()
                    
                    let messageCount = self.model.dataSource.messageCount
                    SPAnalyticsHolder.default.totalComments = messageCount
                    SPAnalyticsHolder.default.log(event: .loaded, source: .conversation)
                    
                    if self.model.areCommentsEmpty() {
                        self.showEmptyStateView()
                    } else {
                        self.hideEmptyStateView()
                        self.header.set(commentCount: messageCount.decimalFormatted)
                        self.footerView.set(commentsCount: messageCount.decimalFormatted)
                        self.stateActionView?.removeFromSuperview()
                        self.stateActionView = nil
                        self.updateCommunityQuestion(communityQuestionText: self.getCommunityQuestion())
                    }
                }
                
                self.updateWhatYouThinkView()
                
                self.tableView.reloadData()
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
                
                self.updateTableViewHeightIfNeeded()
                self.dataLoaded?()
            }
        )
    }

    override func configureEmptyStateView() {
        super.configureEmptyStateView()
        stateActionView?.backgroundColor = .white
        stateActionView?.layout {
            $0.top.equal(to: header.bottomAnchor, offsetBy: 10)
            $0.leading.equal(to: view.leadingAnchor)
            $0.bottom.equal(to: footerView.topAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
    }

    override func createEmptyConversationActionView() -> SPEmptyConversationActionView {
        return SPEmptyConversationActionView(showingIcon: false)
    }

    override func configureErrorAction() -> ConversationStateAction {
        return { [weak self] in
            self?.loadConversation()
        }
    }

    override func configureNoInternetAction() -> ConversationStateAction {
        return { [weak self] in
            self?.loadConversation()
        }
    }

    func showEmptyStateView() {
        self.stateActionView?.removeFromSuperview()
        self.stateActionView = nil
        let callToAction = LocalizationManager.localizedString(key: "Be the first to comment")
        footerView.hideShowMoreCommentsButton()
        whatYouThinkView.setCallToAction(text: callToAction)
    }
    
    func hideEmptyStateView() {
        self.stateActionView?.removeFromSuperview()
        self.stateActionView = nil
        
        footerView.showShowMoreCommentsButton()
        whatYouThinkView.setCallToAction(text: LocalizationManager.localizedString(key: "What do you think?"))
    }

    override func showErrorStateView() {
        super.showErrorStateView()
        footerView.hideShowMoreCommentsButton()
    }

    private func updateWhatYouThinkView() {
        whatYouThinkView.updateAvatar(model.dataSource.currentUserAvatarUrl)
        if self.isButtonOnlyModeEnabled {
            whatYouThinkView.isHidden = true
            whatYouThinkView.layout {
                $0.height.equal(to: 0)
            }
        }
    }

    override func isLastSection(with section: Int) -> Bool {
        return maxSectionCount == section + 1
    }

    override func shouldShowLoader(forRowAt indexPath: IndexPath) -> Bool {
        return model.dataSource.isLoading
    }

    override func cellData(for indexPath: IndexPath) -> CommentViewModel? {
        return model.dataSource.clippedCellData(for: indexPath)
    }

    override func cellDataHeight(for indexPath: IndexPath) -> CGFloat {
        return model.dataSource.clippedCellData(for: indexPath)?.height(with: messageLineLimit) ?? 0
    }
    
    override func dataSource(didChangeRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SPCommentCell,
            let viewModel = model.dataSource.clippedCellData(for: indexPath) {
            cell.setup(with: viewModel,
                       shouldShowHeader: indexPath.section != 0,
                       minimumVisibleReplies: model.dataSource.minVisibleReplies,
                       lineLimit: messageLineLimit)
        }
    }
    
    override func reloadAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateTableViewHeightIfNeeded()
    }
    
    override func removeSectionAt(index: Int) {
        tableView.reloadData()
    }
    
    override func checkAdsAvailability() {
        guard
            !disableAdsForUser(),
            let adsConfig = SPConfigsDataSource.adsConfig,
            let tags = adsConfig.tags
            else { return }
        
        for tag in tags {
            guard let adsId = tag.code else { break }
            switch tag.adType {
            case .banner:
                if model.adsGroup().preConversatioBannerEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .banner), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .banner), source: .conversation)
                    
                    adsProvider.bannerView.subviews.forEach({$0.removeFromSuperview()}) // cleanup previous banners if exists
                    adsProvider.setupAdsBanner(with: adsId, in: self, validSizes: [.small, .medium, .large])
                }
            case .interstitial:
                if model.adsGroup().interstitialEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .interstitial), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .interstitial), source: .conversation)
                    adsProvider.setupInterstitial(with: adsId)
                }
            default:
                break
            }
        }
    }
    
    override func handleCommentSizeChange() {
        super.handleCommentSizeChange()
        
        updateTableViewHeightIfNeeded()
    }
    
    private func didTapComment(with indexPath: IndexPath) {
        let commentId = model.dataSource.clippedCellData(for: indexPath)?.commentId
        moveToFullConversation(selectedCommentId: commentId)
    }
    
    private func moveToFullConversation(selectedCommentId: String?) {
        // show interstitial if needed
        if  model.adsGroup().interstitialEnabled(),
            AdsManager.shouldShowInterstitial(for: model.dataSource.postId) {
            if adsProvider.showInterstitial(in: self) {
                print("Did not showed interstitial")
            }
        }
         preConversationDelegate?.showMoreComments(with: model, selectedCommentId: selectedCommentId)
    }
    
    override func didStartSignInFlow() {
        self.isWaitingForSignIn = true
    }
    
    override func handleUserSignedIn(isAuthenticated: Bool) {
        guard self.isWaitingForSignIn else { return }
        self.isWaitingForSignIn = false
        super.handleUserSignedIn(isAuthenticated: isAuthenticated)
    }
    
    override func handleConversationReloaded(success: Bool, error: SPNetworkError?) {
        self.tableView.reloadData()
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.updateTableViewHeightIfNeeded()
    }
    
    @objc
    private func appMovedToBackground() {
        SPAnalyticsHolder.default.log(event: .appClosed, source: .mainPage)
    }
    
    @objc
    private func overrideUserInterfaceStyleDidChange() {
        self.tableView.reloadData()
        self.updateColorsAccordingToStyle()
    }
}

// MARK: - Extensions

extension SPPreConversationViewController { // UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = super.numberOfSections(in: tableView)
        return numberOfSections < maxSectionCount ? numberOfSections : maxSectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapComment(with: indexPath)
    }
}

extension SPPreConversationViewController: SPPreConversationFooterDelegate {
    
    func updateMoreCommentsButtonCustomUI(button: SPShowCommentsButton) {
        customUIDelegate?.customizeShowCommentsButton(button: button)
    }
    
    
    func showMoreComments() {
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        moveToFullConversation(selectedCommentId: nil)
    }

    func showTerms() {
        preConversationDelegate?.showTerms()
    }

    func showPrivacy() {
        preConversationDelegate?.showPrivacy()
    }

    func showAddSpotIM() {
        preConversationDelegate?.showAddSpotIM()
    }
}

extension SPPreConversationViewController { // SPCommentCellDelegate

    override func showMoreReplies(for commentId: String?) {
        moveToFullConversation(selectedCommentId: commentId)
    }

}

extension SPPreConversationViewController: AdsProviderBannerDelegate {
    func bannerLoaded(adBannerSize: CGSize) {
        let bannerView = adsProvider.bannerView
        
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .banner), source: .conversation)
 
        self.bannerView.layout {
            $0.height.equal(to: adBannerSize.height)
        }
        
        self.bannerView.update(bannerView, height: adBannerSize.height)
        
        self.bannerVisisilityTracker.startTracking()
    }
    
    func bannerFailedToLoad(error: Error) {
        Logger.error("error bannerFailedToLoad - \(error)")
        let monetizationFailureData = MonetizationFailureModel(source: .preConversation, reason: error.localizedDescription, bannerType: .banner)
        SPDefaultFailureReporter.shared.sendMonetizationFaliureReport(monetizationFailureData)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .banner), source: .conversation)
    }
}

extension SPPreConversationViewController: AdsProviderInterstitialDelegate {
    func interstitialLoaded() {
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .interstitial), source: .conversation)
    }
    
    func interstitialWillBeShown() {
        AdsManager.willShowInterstitial(for: model.dataSource.postId)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonetizationView, .interstitial), source: .conversation)
    }
    
    func interstitialDidDismiss() {
        
    }
    
    func interstitialFailedToLoad(error: Error) {
        let monetizationFailureData = MonetizationFailureModel(source: .preConversation, reason: error.localizedDescription, bannerType: .interstitial)
        SPDefaultFailureReporter.shared.sendMonetizationFaliureReport(monetizationFailureData)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .interstitial), source: .conversation)
    }
}

extension SPPreConversationViewController: CommentsCounterDelegate {
    func commentsCountDidUpdate(count: Int) {
        self.header.set(commentCount: count.decimalFormatted)
        self.footerView.set(commentsCount: count.decimalFormatted)
    }
}

extension SPPreConversationViewController: ViewVisibilityDelegate {
    func viewDidBecomeVisible(view: UIView) {
        if view == self.view {
            if !didBecomeVisible {
                didBecomeVisible = true
                SPAnalyticsHolder.default.log(event: .viewed, source: .conversation)
            }
            let delay = (SPConfigsDataSource.appConfig?.realtime?.startTimeoutMilliseconds ?? 5000) / 1000
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                self.model.startTypingTracking()
            }
            
            readingTracker.startReadingTracking()
        }
        
        if view == self.bannerView {
            SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonetizationView, .banner), source: .conversation)
            self.bannerVisisilityTracker.shutdown()
        }
    }
    
    func viewDidDisappear(view: UIView) {
        if view == self.view {
            readingTracker.stopReadingTracking()
        }
    }
}
private extension SPPreConversationViewController {

    private enum Theme {
        static let whatYouThinkHeight: CGFloat = 64
        static let headerHeight: CGFloat = 50
        static let bannerViewMargin: CGFloat = 40
    }

}

// MARK: - Delegate

internal protocol SPPreConversationViewControllerDelegate: class {
    func showMoreComments(with dataModel: SPMainConversationModel, selectedCommentId: String?)
    func showTerms()
    func showPrivacy()
    func showAddSpotIM()
    func viewHeightDidChange(to newValue: CGFloat)
}
