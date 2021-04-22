//
//  SPMainConversationViewController.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 17/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPCommentsCreationDelegate: class {
    func createComment(with dataModel: SPMainConversationModel)
    func createReply(with dataModel: SPMainConversationModel, to id: String)
}

final class SPMainConversationViewController: SPBaseConversationViewController, UserPresentable {
    
    enum ScrollingDirection {
        case up, down, `static`
    }
    
    var commentIdToShowOnOpen: String?
    
    let adsProvider: AdsProvider
        
    private let sortView = SPConversationSummaryView()

    private lazy var refreshControl = UIRefreshControl()
    private lazy var tableHeader = SPArticleHeader()
    private lazy var loginPromptView = SPLoginPromptView()
    private lazy var communityGuidelinesView = SPCommunityGuidelinesView()
    private lazy var footer = SPMainConversationFooterView()
    private var typingIndicationView: TotalTypingIndicationView?

    internal override var screenTargetType: SPAnScreenTargetType {
        return .main
    }

    // MARK: - Header scrolling properties
    
    private let articleHeaderMaxHeight: CGFloat = 85.0
    private let articleHeaderMinHeight: CGFloat = 0.0
    
    private var footerHeightConstraint: NSLayoutConstraint?
    private var headerHeightConstraint: NSLayoutConstraint?
    private var currentHeightConstant: CGFloat = 0.0
    private var initialOffsetY: CGFloat = 0.0
    private var lastOffsetY: CGFloat = 0.0
    private var isDragging: Bool = false
    private var isHeaderVisible: Bool = false
    private var wasScrolled: Bool = false
    private var displayArticleHeader: Bool = true
    private var communityGuidelinesHtmlString: String? = nil
    
    private var isCommunityGuidelinesVisible: Bool = false
    private var communityGuidelinesMaxHeight: CGFloat = 0.0  // Being update in viewDidLayoutSubviews
    private var communityGuidelinesMinHeight: CGFloat = 0.0
    private var communityGuidelinesHeightConstraint: NSLayoutConstraint?
    
    private var shouldDisplayLoginPrompt: Bool = false
    private var isLoginPromtVisible: Bool = false
    private var loginPromptMaxHeight: CGFloat = 0.0  // Being update in viewDidLayoutSubviews
    private var loginPromptMinHeight: CGFloat = 0.0
    private var loginPromptHeightConstraint: NSLayoutConstraint?

    private var scrollingDirection: ScrollingDirection = .static {
        didSet {
            if oldValue != scrollingDirection {
                currentHeightConstant = headerHeightConstraint?.constant ?? 0.0
                initialOffsetY = lastOffsetY
            }
        }
    }

    init(model: SPMainConversationModel, adsProvider: AdsProvider) {
        Logger.verbose("FirstComment: Main view controller created")
        self.adsProvider = adsProvider
        self.displayArticleHeader = SpotIm.displayArticleHeader
        super.init(model: model)
        
        adsProvider.bannerDelegate = self
    }
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Logger.verbose("FirstComment: Main view did load")
        if SPAnalyticsHolder.default.pageViewId != SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId {
            SPAnalyticsHolder.default.log(event: .mainViewed, source: .conversation)
            SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId = SPAnalyticsHolder.default.pageViewId
        }
        checkAdsAvailability()
        updateHeaderUI()
        configureModelHandlers()
        
        if let loginUIEnabled = SPConfigsDataSource.appConfig?.mobileSdk.loginUiEnabled, loginUIEnabled {
            setupUserIconHandler()
        }

        Logger.verbose("FirstComment: Have some comments in the data source")
        updateFooterView()
        sortView.updateCommentsLabel(model.dataSource.messageCount)
        NotificationCenter.default.addObserver(
           self,
           selector: #selector(overrideUserInterfaceStyleDidChange),
           name: Notification.Name(SpotIm.OVERRIDE_USER_INTERFACE_STYLE_NOTIFICATION),
           object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isCommunityGuidelinesVisible && communityGuidelinesHeightConstraint == nil {
            communityGuidelinesMaxHeight = communityGuidelinesView.frame.height
            communityGuidelinesView.layout {
                communityGuidelinesHeightConstraint = $0.height.equal(to: communityGuidelinesView.frame.height)
            }
        }
        if isLoginPromtVisible && loginPromptHeightConstraint == nil {
            loginPromptMaxHeight = loginPromptView.frame.height
            loginPromptView.layout {
                loginPromptHeightConstraint = $0.height.equal(to: loginPromptView.frame.height)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.view.backgroundColor = .spBackground0
        self.tableView.backgroundColor = .spBackground0
        self.footer.updateColorsAccordingToStyle()
        self.tableHeader.updateColorsAccordingToStyle()
        self.sortView.updateColorsAccordingToStyle()
        self.communityGuidelinesView.updateColorsAccordingToStyle()
        if let htmlString = self.communityGuidelinesHtmlString {
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
        }
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
    
    @objc
    private func overrideUserInterfaceStyleDidChange() {
        self.tableView.reloadData()
        self.updateColorsAccordingToStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        model.delegates.add(delegate: self)
        model.commentsCounterDelegates.add(delegate: self)
        
        do {
            let typingCount = try model.typingCount()
            totalTypingCountDidUpdate(count: typingCount)
        } catch {
            if let realtimeError = error as? RealTimeErorr {
                model.stopRealTimeFetching()
                let realtimeFailureReport = RealTimeFailureModel(reason: realtimeError.description)
                SPDefaultFailureReporter.shared.sendRealTimeFailureReport(realtimeFailureReport)
            }
        }
        
        if model.dataSource.messageCount > 0 {
            sortView.updateCommentsLabel(model.dataSource.messageCount)
        }
        
        // scroll to pre-selected comment (tapped on the Pre-Conversation)
        if let indexPath = model.dataSource.indexPathOfComment(with: commentIdToShowOnOpen) {
            wasScrolled = true
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        } else if tableView.cellForRow(at: IndexPath(row: 0, section: 0)) != nil && !wasScrolled {
            wasScrolled = true
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        commentIdToShowOnOpen = nil
    }
    
    override func handleConversationReloaded(success: Bool, error: SPNetworkError?) {
        Logger.verbose("FirstComment: API did finish with \(success)")
        self.hideLoader()
        self.refreshControl.endRefreshing()

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
            Logger.verbose("FirstComment: Did get result, saving data from backend \(self.model.dataSource.messageCount)")
            let messageCount = self.model.dataSource.messageCount
            SPAnalyticsHolder.default.totalComments = messageCount
            self.sortView.updateCommentsLabel(messageCount)
            
            self.stateActionView?.removeFromSuperview()
            self.stateActionView = nil
            self.tableView.scrollRectToVisible(.init(x: 0, y: 0 , width: 1, height: 1), animated: true)
        }
        Logger.verbose("FirstComment: Calling reload on table view")
        self.tableView.reloadData()
        self.updateHeaderUI()
        self.updateFooterView()
    }
    
    @objc
    private func showProfile() {
        showProfileActions(sender: userIcon)
    }
    
    func setupUserIconHandler() {
        userRightBarItem = UIBarButtonItem(customView: userIcon)
        userIcon.addTarget(self, action: #selector(showProfile), for: .touchUpInside)
        navigationItem.setRightBarButton(userRightBarItem!, animated: true)
    }

    // MARK: - Private Methods
    
    private func configureModelHandlers() {
        model.sortingUpdateHandler = { [weak self] shoudBeUpdated in
            guard let self = self else { return }

            let sortOption = self.model.sortOption
            
            self.sortView.updateSortOption(sortOption.title)
            if shoudBeUpdated {
                self.reloadConversation()
            }
        }
    }

    private func loadCommentsNextPage() {
        guard !model.dataSource.isLoading else { return }
        
        Logger.warn("DEBUG: Loading next page")
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        let mode = model.sortOption
        model.dataSource.comments(
            mode,
            page: .next,
            loadingStarted: {
                // showing loader section
                Logger.warn("DEBUG: Loading started called")
                self.tableView.reloadData()
            },
            loadingFinished: {
                // Removing loader section
                Logger.warn("DEBUG: Loading finished called")
                self.tableView.reloadData()
            },
            completion: { (success, _, error) in
                if let error = error {
                    self.showAlert(
                        title: LocalizationManager.localizedString(key: "Oops..."),
                        message: error.localizedDescription
                    )
                } else if success == false {
                    Logger.error("Load conversation next page request type is not `success`")
                } else {
                    self.sortView.updateCommentsLabel(self.model.dataSource.messageCount)
                }
                
                self.tableView.reloadData()
            }
        )
    }

    override func setupUI() {
        view.addSubviews(footer, sortView, tableHeader, loginPromptView, communityGuidelinesView)

        super.setupUI()
    
        setupSortView()
        configureLoginPromptView()
        configureCommunityGuidelinesView()
        configureTableHeaderView()
        setupFooterView()
        setupRefreshControl()
    }

    private func setupSortView() {
        view.bringSubviewToFront(sortView)
        sortView.dropsShadow = !SPUserInterfaceStyle.isDarkMode
        sortView.delegate = self
        sortView.updateSortOption(model.sortOption.title)
        sortView.layout {
            $0.top.equal(to: topLayoutGuide.bottomAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.height.equal(to: 44.0)
        }
    }
    
    private func configureLoginPromptView() {
        loginPromptView.layout {
            $0.top.equal(to: sortView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        if self.shouldDisplayLoginPrompt {
            isLoginPromtVisible = true
            loginPromptView.delegate = self
            view.bringSubviewToFront(loginPromptView)
            loginPromptView.clipsToBounds = true
        } else {
            loginPromptView.isHidden = true
            loginPromptView.layout {
                $0.height.equal(to: 0.0)
            }
        }
    }
    
    private func configureCommunityGuidelinesView() {
        communityGuidelinesView.layout {
            $0.top.equal(to: loginPromptView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
        }
        if let htmlString = getCommunityGuidelinesTextIfExists() {
            communityGuidelinesHtmlString = htmlString
            isCommunityGuidelinesVisible = true
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
            communityGuidelinesView.delegate = self
            view.bringSubviewToFront(communityGuidelinesView)
            communityGuidelinesView.clipsToBounds = true
        } else {
            communityGuidelinesView.isHidden = true
            communityGuidelinesView.layout {
                $0.height.equal(to: 0.0)
            }
        }
    }
    
    private func configureTableHeaderView() {
        if (self.displayArticleHeader == false) {
            tableHeader.removeFromSuperview()
            return
        }
        view.bringSubviewToFront(tableHeader)
        tableHeader.clipsToBounds = true
        tableHeader.layout {
            $0.top.equal(to: communityGuidelinesView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            headerHeightConstraint = $0.height.equal(to: 0.0)
        }
    }
    
    override func setupTableView() {
        super.setupTableView()

        tableView.layout {
            $0.top.equal(to: self.displayArticleHeader ? tableHeader.bottomAnchor : communityGuidelinesView.bottomAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.bottom.equal(to: footer.topAnchor)
        }
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
                if model.adsGroup().mainConversationBannerEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .banner), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .banner), source: .conversation)
                    adsProvider.setupAdsBanner(with: adsId, in: self, validSizes: [.small])
                }
            default:
                break
            }
        }
    }
    
    private func setupFooterView() {
        view.bringSubviewToFront(footer)
        footer.updateOnlineStatus(.online)
        footer.delegate = self
        footer.dropsShadow = !SPUserInterfaceStyle.isDarkMode
        footer.layout {
            footerHeightConstraint = $0.height.equal(to: 80.0)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.bottom.equal(to: view.layoutMarginsGuide.bottomAnchor)
        }
    }
    
    private func updateFooterView() {
        footer.updateColorsAccordingToStyle()
        footer.updateAvatar(model.dataSource.currentUserAvatarUrl)
        model.fetchNavigationAvatar { [weak self] image, _ in
            guard
                let self = self,
                let image = image
                else { return }
            self.updateUserIcon(image: image)
        }
    }
    
    private func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(reloadConversation), for: .valueChanged)
    }

    private func insertLoaderCell() {
        let loaderIndexPath = IndexPath(row: 0, section: model.dataSource.numberOfSections())
        tableView.insertRows(at: [loaderIndexPath], with: .automatic)
    }

    override func shouldShowLoader(forRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == model.dataSource.numberOfSections() - 1 && model.dataSource.isLoading
    }

    private func loadNextPageIfNeeded(forRowAt indexPath: IndexPath) {
        guard
            model.dataSource.canLoadNextPage && model.dataSource.isTimeToLoadNextPage(forRowAt: indexPath)
            else { return }

        loadCommentsNextPage()
    }

    private func updateHeaderUI() {
        if self.displayArticleHeader == false {
            return
        }
        isHeaderVisible = true
        headerHeightConstraint?.constant = articleHeaderMaxHeight
        tableHeader.setAuthor(model.dataSource.articleMetadata.subtitle)
        tableHeader.setImage(with: URL(string: model.dataSource.articleMetadata.thumbnailUrl))
        tableHeader.setTitle(model.dataSource.articleMetadata.title)
    }

    override func configureEmptyStateView() {
        super.configureEmptyStateView()
        
        view.bringSubviewToFront(sortView)
        stateActionView?.layout {
            $0.bottom.equal(to: view.layoutMarginsGuide.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.top.equal(to: sortView.bottomAnchor)
        }
    }

    override func configureErrorAction() -> ConversationStateAction {
        return { [weak self] in
            self?.showLoader()
            self?.reloadConversation()
        }
    }

    override func configureNoInternetAction() -> ConversationStateAction {
        return { [weak self] in
            self?.showLoader()
            self?.reloadConversation()
        }
    }
    
    override func isLastSection(with section: Int) -> Bool {
        return model.dataSource.numberOfSections() == section + 1
    }
}

extension SPMainConversationViewController { // UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        loadNextPageIfNeeded(forRowAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canAnimateHeader(scrollView) else { return }
        
        handleArticleHeight(with: scrollView.contentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard canAnimateHeader(scrollView) else { return }
        
        isDragging = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard canAnimateHeader(scrollView) else { return }
        
        handleFinalHeaderHeightUpdate(with: scrollView.contentOffset)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard canAnimateHeader(scrollView) else { return }
        
        isDragging = false
        if !decelerate {
            handleFinalHeaderHeightUpdate(with: scrollView.contentOffset)
        }
    }
}

extension SPMainConversationViewController { // SPMainConversationDataSourceDelegate
    
    override func reload(shouldBeScrolledToTop: Bool) {
        stateActionView?.removeFromSuperview()
        stateActionView = nil
        
        if shouldBeScrolledToTop {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
        sortView.updateCommentsLabel(model.dataSource.messageCount)
        tableView.reloadData()
    }
    
    override func reload(scrollToIndexPath: IndexPath?) {
        tableView.reloadData()

        guard let indexPath = scrollToIndexPath else { return }
        
        let scrollPosition: UITableView.ScrollPosition = tableView.cellForRow(at: indexPath) == nil
            ? .bottom
            : .none
        tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
    }
}

extension SPMainConversationViewController { // SPCommentCellDelegate

    override func showMoreReplies(for commentId: String?) {
        if let commentId = commentId {
            let relatedCommentId = model.dataSource.commentViewModel(commentId)?.rootCommentId
            SPAnalyticsHolder.default.log(
                event: .loadMoreRepliesClicked(
                    messageId: commentId,
                    relatedMessageId: relatedCommentId),
                source: .conversation)
        }
        model.dataSource.showMoreReplies(for: commentId, sortMode: model.sortOption)
    }
}

extension SPMainConversationViewController: SPConversationSummaryViewDelegate {
    
    func newCommentsDidTap(_ summaryView: SPConversationSummaryView) {
        
    }
    
    func sortingDidTap(_ summaryView: SPConversationSummaryView, sender: UIView) {
        SPAnalyticsHolder.default.log(event: .sortByOpened, source: .conversation)
        showActionSheet(
            title: LocalizationManager.localizedString(key: "Sort By"),
            message: nil,
            actions: model.sortActions(),
            sender: sender)
    }
    
}

extension SPMainConversationViewController { // Article header scrolling logic
    
    /// Takes care of article header height updates using scrollView contentOffset vaule
    private func handleArticleHeight(with scrollViewContentOffset: CGPoint) {
        let currentOffsetY = scrollViewContentOffset.y
        if isDragging {
            scrollingDirection = currentOffsetY > lastOffsetY ? .up : .down
        }
        lastOffsetY = currentOffsetY

        updateCommunityGuidelinedHeightInstantly()
        updateHeaderHeightInstantly()
    }
    
    /// Instantly updates article header height when scrollView is scrolling
    private func updateCommunityGuidelinedHeightInstantly() {
        guard isCommunityGuidelinesVisible else { return }
        if scrollingDirection == .down && communityGuidelinesHeightConstraint?.constant == communityGuidelinesMaxHeight {
            return
        }
        if lastOffsetY > 0 {
            if (scrollingDirection == .down && lastOffsetY > communityGuidelinesMaxHeight) {
                return
            }
            
            let calculatedHeight = communityGuidelinesMaxHeight - lastOffsetY
            let newHeight: CGFloat = max(calculatedHeight, 0)
            
            communityGuidelinesHeightConstraint?.constant = newHeight
        } else {
            communityGuidelinesHeightConstraint?.constant = communityGuidelinesMaxHeight
        }
    }
    
    /// Instantly updates article header height when scrollView is scrolling
    private func updateHeaderHeightInstantly() {
        guard isHeaderVisible else { return }
        
        guard !isCommunityGuidelinesVisible || communityGuidelinesHeightConstraint?.constant == communityGuidelinesMinHeight else { return }
        
        if lastOffsetY > 0 {
            var calculatedHeight = currentHeightConstant - (lastOffsetY - initialOffsetY)
            if isCommunityGuidelinesVisible {
                calculatedHeight += (lastOffsetY < communityGuidelinesMaxHeight + communityGuidelinesMaxHeight) ? communityGuidelinesMaxHeight : 0
            }
            
            let newHeight: CGFloat = max(min(calculatedHeight, articleHeaderMaxHeight), articleHeaderMinHeight)
            
            headerHeightConstraint?.constant = newHeight
        } else {
            headerHeightConstraint?.constant = articleHeaderMaxHeight
        }
    }
    
    /// Updates article header height after scroll view did end actions using `scrollingDirection` property
    private func handleFinalHeaderHeightUpdate(with scrollViewContentOffset: CGPoint) {
        guard scrollingDirection != .static else { return }
        
        if (isLoginPromtVisible) {
            let finalHeightLoginPrompt: CGFloat
            if (scrollViewContentOffset.y <= loginPromptMaxHeight * 0.8) {
                finalHeightLoginPrompt = loginPromptMaxHeight
            } else {
                finalHeightLoginPrompt = (loginPromptHeightConstraint?.constant ?? 0) < loginPromptMaxHeight * 0.5 ? loginPromptMinHeight : loginPromptMaxHeight
            }
                
            loginPromptHeightConstraint?.constant = finalHeightLoginPrompt
        }
        
        if (isCommunityGuidelinesVisible) {
            let finaleHeightCommunityGuidelines: CGFloat
            if (scrollViewContentOffset.y <= communityGuidelinesMaxHeight * 0.8) {
                finaleHeightCommunityGuidelines = communityGuidelinesMaxHeight
            } else {
                finaleHeightCommunityGuidelines = (communityGuidelinesHeightConstraint?.constant ?? 0) < communityGuidelinesMaxHeight * 0.5 ? communityGuidelinesMinHeight : communityGuidelinesMaxHeight
            }
                
            communityGuidelinesHeightConstraint?.constant = finaleHeightCommunityGuidelines
        }
        
        if (isHeaderVisible) {
            let finaleHeight: CGFloat = (headerHeightConstraint?.constant ?? 0) < articleHeaderMaxHeight * 0.5 ? articleHeaderMinHeight: articleHeaderMaxHeight
            headerHeightConstraint?.constant = finaleHeight
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        scrollingDirection = .static
    }
    
    private func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        let scrollViewMaxHeight = scrollView.frame.height + (self.headerHeightConstraint?.constant ?? 0) + articleHeaderMaxHeight
        return scrollView.contentSize.height > scrollViewMaxHeight
    }

}

extension SPMainConversationViewController: AdsProviderBannerDelegate {
    func bannerLoaded(adBannerSize: CGSize) {
        let bannerView = adsProvider.bannerView
        
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .banner), source: .conversation)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonetizationView, .banner), source: .conversation)
        footerHeightConstraint?.constant = 80.0 + adBannerSize.height + 16.0
        footer.updateBannerView(bannerView, height: adBannerSize.height)
    }
    
    func bannerFailedToLoad(error: Error) {
        Logger.error("error bannerFailedToLoad - \(error)")
        let monetizationFailureData = MonetizationFailureModel(source: .mainConversation, reason: error.localizedDescription, bannerType: .banner)
        SPDefaultFailureReporter.shared.sendMonetizationFaliureReport(monetizationFailureData)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .banner), source: .conversation)
    }
}

extension SPMainConversationViewController: CommentsCounterDelegate {
    func commentsCountDidUpdate(count: Int) {
        self.sortView.updateCommentsLabel(count)
    }
}
