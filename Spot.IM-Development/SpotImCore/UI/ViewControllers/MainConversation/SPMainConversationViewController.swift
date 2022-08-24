//
//  SPMainConversationViewController.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 17/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPCommentsCreationDelegate: AnyObject {
    func createComment(with dataModel: SPMainConversationModel)
    func createReply(with dataModel: SPMainConversationModel, to id: String)
    func editComment(with dataModel: SPMainConversationModel, to id: String)
}

final class SPMainConversationViewController: SPBaseConversationViewController, OWUserPresentable {

    enum ScrollingDirection {
        case up, down, `static`
    }

    var commentIdToShowOnOpen: String?

    let adsProvider: AdsProvider

    private let summaryView = SPConversationSummaryView()

    private lazy var refreshControl = UIRefreshControl()
    private lazy var articleHeader = OWArticleHeader()
    private lazy var loginPromptView = SPLoginPromptView()
    private lazy var collapsableContainer = OWBaseView()
    private lazy var communityQuestionView = SPCommunityQuestionView()
    private lazy var communityGuidelinesView = SPCommunityGuidelinesView()
    private lazy var footer = SPMainConversationFooterView()
    
    private var bannerView: UIView?

    internal override var screenTargetType: SPAnScreenTargetType {
        return .main
    }
    
    // true if the full conversation is opened via present/push and not from pre-conversation
    internal var openedByPublisher = false

    // MARK: - Header scrolling properties

    private let articleHeaderMaxHeight: CGFloat = 85.0
    private let articleHeaderMinHeight: CGFloat = 0.0

    private var currentHeightConstant: CGFloat = 0.0
    private var initialOffsetY: CGFloat = 0.0
    private var lastOffsetY: CGFloat = 0.0
    private var isDragging: Bool = false
    private var isHeaderVisible: Bool = false
    private var wasScrolled: Bool = false
    private var displayArticleHeader: Bool = true
    private var communityGuidelinesHtmlString: String? = nil

    private var shouldDisplayCommunityGuidelines: Bool = false
    private var shouldDisplayCommunityQuestion: Bool = false
    private var shouldDisplayCollapsableContainer: Bool {
        shouldDisplayCommunityGuidelines || shouldDisplayCommunityQuestion
    }

    private var collapsableContainerMaxHeight: CGFloat = 0.0  // Being update in viewDidLayoutSubviews
    private var collapsableContainerMinHeight: CGFloat = 0.0
    private var collapsableContainerHeightConstraint: OWConstraint?

    weak override var userAuthFlowDelegate: OWUserAuthFlowDelegate? {
        didSet {
            self.shouldDisplayLoginPrompt = self.userAuthFlowDelegate?.shouldDisplayLoginPromptForGuests() ?? false
        }
    }

    var shouldDisplayLoginPrompt: Bool = false {
        didSet {
            updateLoginPromptVisibily()
        }
    }

    private var scrollingDirection: ScrollingDirection = .static {
        didSet {
            if oldValue != scrollingDirection {
                currentHeightConstant = articleHeader.frame.height
                initialOffsetY = lastOffsetY
            }
        }
    }

    init(model: SPMainConversationModel, adsProvider: AdsProvider, customUIDelegate: OWCustomUIDelegate?, openedByPublisher: Bool = false) {
        self.adsProvider = adsProvider
        self.displayArticleHeader = SpotIm.displayArticleHeader
        self.openedByPublisher = openedByPublisher
        super.init(model: model, customUIDelegate: customUIDelegate)
        adsProvider.bannerDelegate = self
        self.shouldDisplayLoginPrompt = self.userAuthFlowDelegate?.shouldDisplayLoginPromptForGuests() ?? false
        servicesProvider.logger().log(level: .verbose, "FirstComment: Main view controller created")
    }
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        servicesProvider.logger().log(level: .verbose, "FirstComment: Main view did load")

        if SPAnalyticsHolder.default.pageViewId != SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId {
            SPAnalyticsHolder.default.log(event: openedByPublisher ? .viewed : .mainViewed, source: .conversation)
            SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId = SPAnalyticsHolder.default.pageViewId
        }

        updateHeaderUI()
        configureModelHandlers()

        if let loginUIEnabled = SPConfigsDataSource.appConfig?.mobileSdk.loginUiEnabled, loginUIEnabled {
            setupUserIconHandler()
        }

        servicesProvider.logger().log(level: .verbose, "FirstComment: Have some comments in the data source")

        updateFooterView()
        footer.commentCreationEntryView.configure(with: model.convCommetEntryVM, delegate: self)
        articleHeader.configure(with: model.articleHeaderVM)
        summaryView.configure(with: model.conversationSummaryVM)

        if model.areCommentsEmpty() {
            showEmptyStateView()
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.userLoginSuccessNotification(notification:)),
            name: Notification.Name(SpotImSDKFlowCoordinator.USER_LOGIN_SUCCESS_NOTIFICATION),
            object: nil)
        
        startRealtimeService()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldDisplayCollapsableContainer && collapsableContainerHeightConstraint == nil {
            collapsableContainerMaxHeight = collapsableContainer.frame.height
            collapsableContainer.OWSnp.makeConstraints { make in
                collapsableContainerHeightConstraint = make.height.equalTo(collapsableContainer.frame.height).constraint
            }
        }
    }
    
    override func viewDidChangeWindowSize() {
        super.viewDidChangeWindowSize()
        self.resetCollapsableContainerHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.updateColorsAccordingToStyle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.removeBannerFromConversation()
        }
    }

    func updateLoginPromptVisibily() {
        if self.shouldDisplayLoginPrompt && SPUserSessionHolder.session.user?.id == nil {
            // publisher point of integration - this is where NY Post for example can configure text, font, color, etc, etc
            self.customUIDelegate?.customizeLoginPromptTextView(textView: loginPromptView.getTextView())
        }
        else {
            loginPromptView.isHidden = true
            loginPromptView.OWSnp.makeConstraints { make in
                make.height.equalTo(0)
            }
        }
    }

    @objc func userLoginSuccessNotification(notification: Notification) {
        self.shouldDisplayLoginPrompt = false
    }


    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        self.view.backgroundColor = .spBackground0
        self.tableView.backgroundColor = .spBackground0
        self.footer.updateColorsAccordingToStyle()
        self.updateFooterViewCustomUI(footerView: self.footer)
        self.articleHeader.updateColorsAccordingToStyle()
        self.summaryView.updateColorsAccordingToStyle()
        self.loginPromptView.updateColorsAccordingToStyle()
        self.communityQuestionView.updateColorsAccordingToStyle()
        self.updateCommunityQuestionCustomUI(communityQuestionView: self.communityQuestionView)
        self.communityGuidelinesView.updateColorsAccordingToStyle()
        if let htmlString = self.communityGuidelinesHtmlString {
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
        }
        self.updateEmptyStateViewAccordingToStyle()
        self.typingIndicationView?.updateColorsAccordingToStyle()
        // publisher point of integration - this is where NY Post for example can configure text, font, color, etc, etc
        self.customUIDelegate?.customizeLoginPromptTextView(textView: loginPromptView.getTextView())
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

    @objc override func overrideUserInterfaceStyleDidChange() {
        super.overrideUserInterfaceStyleDidChange()
        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAdsAvailability()

        model.delegates.add(delegate: self)
        model.currentBindedVC = .conversation

        do {
            let typingCount = try model.typingCount()
            let newCommentsCount = model.newMessagesCount()
            totalTypingCountDidUpdate(count: typingCount, newCommentsCount: newCommentsCount)
        } catch {
            if let realtimeError = error as? RealTimeError {
                model.stopRealTimeFetching()
                SPDefaultFailureReporter.shared.report(error: .realTimeError(realtimeError))
            }
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
        let logger = servicesProvider.logger()
        logger.log(level: .verbose, "FirstComment: API did finish with \(success)")

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
            logger.log(level: .error, "Load conversation request type is not `success`")
        } else {
            logger.log(level: .verbose, "FirstComment: Did get result, saving data from backend \(self.model.dataSource.messageCount)")
            let messageCount = self.model.dataSource.messageCount
            SPAnalyticsHolder.default.totalComments = messageCount
            // show/hide empty view if needed
            if self.model.areCommentsEmpty(){
                showEmptyStateView()
            } else {
                hideEmptyStateView()
            }
            self.tableView.scrollRectToVisible(.init(x: 0, y: 0 , width: 1, height: 1), animated: true)
        }
        logger.log(level: .verbose, "FirstComment: Calling reload on table view")
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
    
    private func resetCollapsableContainerHeight() {
        guard shouldDisplayCollapsableContainer else { return }

        // remove previous height constraint
        if let heightConstraint = collapsableContainerHeightConstraint {
            heightConstraint.deactivate()
            collapsableContainerHeightConstraint = nil
        }
        
        // recalculate height of subviews
        // This will trigger `viewDidLayoutSubviews` method after orientation change, in which
        // the frame of the collapsableContainer will update and we will re-make the height constarint
        collapsableContainer.setNeedsLayout()
        collapsableContainer.layoutIfNeeded()
    }

    private func configureModelHandlers() {
        model.sortingUpdateHandler = { [weak self] shoudBeUpdated in
            guard let self = self else { return }

            if shoudBeUpdated {
                self.reloadConversation()
            }
        }
    }

    private func loadCommentsNextPage() {
        guard !model.dataSource.isLoading else { return }
        
        let logger = servicesProvider.logger()
        logger.log(level: .verbose, "Loading comments next page")
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        let mode = model.sortOption
        model.dataSource.comments(
            mode,
            page: .next,
            loadingStarted: { [weak logger, weak self] in
                // showing loader section
                logger?.log(level: .verbose, "Comments - loading started called")
                self?.tableView.reloadData()
            },
            loadingFinished: { [weak logger, weak self] in
                // Removing loader section
                logger?.log(level: .verbose, "Comments - loading finished called")
                self?.tableView.reloadData()
            },
            completion: { [weak logger, weak self] (success, _, error) in
                if let error = error {
                    self?.showAlert(
                        title: LocalizationManager.localizedString(key: "Oops..."),
                        message: error.localizedDescription
                    )
                } else if success == false {
                    logger?.log(level: .error, "Load conversation next page request type is not `success`")
                }

                self?.tableView.reloadData()
            }
        )
    }

    override func setupUI() {
        view.addSubviews(footer, summaryView, articleHeader, loginPromptView, collapsableContainer)
        super.setupUI()

        setupSummaryView()
        configureLoginPromptView()
        configureCollapsableContainer()
        configureCommunityGuidelinesView()
        configureCommunityQuestionView()
        configureTableHeaderView()
        setupFooterView()
        setupRefreshControl()
    }

    private func setupSummaryView() {
        view.bringSubviewToFront(summaryView)
        summaryView.dropsShadow = !SPUserInterfaceStyle.isDarkMode
        summaryView.delegate = self
        summaryView.OWSnp.makeConstraints { make in
            make.top.equalTo(loginPromptView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44.0)
        }
    }

    private func configureLoginPromptView() {
        loginPromptView.OWSnp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        loginPromptView.delegate = self
        view.bringSubviewToFront(loginPromptView)
        loginPromptView.clipsToBounds = true
    }

    private func configureCollapsableContainer() {
        collapsableContainer.addSubviews(communityGuidelinesView, communityQuestionView)
        collapsableContainer.OWSnp.makeConstraints { make in
            make.top.equalTo(summaryView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func configureCommunityGuidelinesView() {
        communityGuidelinesView.backgroundColor = .red
        // set constratings with priority for the community guideline to collaps properly when scrolling
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().priority(300)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(communityQuestionView.OWSnp.top).priority(500)
        }
        if let htmlString = getCommunityGuidelinesTextIfExists() {
            communityGuidelinesHtmlString = htmlString
            shouldDisplayCommunityGuidelines = true
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
            communityGuidelinesView.delegate = self
            collapsableContainer.bringSubviewToFront(communityGuidelinesView)
            communityGuidelinesView.clipsToBounds = true
        } else {
            communityGuidelinesView.isHidden = true
            shouldDisplayCommunityGuidelines = false
            communityGuidelinesView.OWSnp.makeConstraints { make in
                make.height.equalTo(0.0)
            }
        }
    }

    private func configureCommunityQuestionView() {
        communityQuestionView.clipsToBounds = true
        updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
        // set constratings with priority for the community question to collaps properly when scrolling
        communityQuestionView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityGuidelinesView.OWSnp.bottom).priority(500)
            make.bottom.equalToSuperview().priority(1000)
            make.leading.trailing.equalToSuperview()
        }

        let communityQuestionText = getCommunityQuestion()
        if let communityQuestionText = communityQuestionText, communityQuestionText.length > 0 {
            communityQuestionView.setupCommunityQuestion(with: communityQuestionText)
            communityQuestionView.clipsToBounds = true
            shouldDisplayCommunityQuestion = true
        } else {
            communityQuestionView.isHidden = true
            communityQuestionView.OWSnp.makeConstraints { make in
                make.height.equalTo(0.0)
            }
            shouldDisplayCommunityQuestion = false
        }
    }

    private func configureTableHeaderView() {
        if (self.displayArticleHeader == false) {
            articleHeader.removeFromSuperview()
            return
        }
        view.bringSubviewToFront(articleHeader)
        articleHeader.clipsToBounds = true
        articleHeader.OWSnp.makeConstraints { make in
            make.top.equalTo(collapsableContainer.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }

    override func setupTableView() {
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(displayArticleHeader ? articleHeader.OWSnp.bottom : collapsableContainer.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footer.OWSnp.top)
        }
    }
    
    override func setupAds(for tags: [SPAdsConfigurationTag]) {
        for tag in tags {
            guard let adsId = tag.code else { break }
            switch tag.adType {
            case .banner:
                if model.adsGroup().mainConversationBannerInFooterEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .banner), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .banner), source: .conversation)
                    adsProvider.setupAdsBanner(with: adsId, in: self, validSizes: [.small])
                }
                break
            case .fullConversationBanner:
                if model.adsGroup().mainConversationBannerEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .banner), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .banner), source: .conversation)
                    adsProvider.setupAdsBanner(with: adsId, in: self, validSizes: [.large])
                }
            default:
                break
            }
        }
    }

    private func setupFooterView() {
        view.bringSubviewToFront(footer)
        footer.dropsShadow = !SPUserInterfaceStyle.isDarkMode
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *), SpotIm.shouldConversationFooterStartFromBottomAnchor {
            bottomPadding = UIApplication.shared.windows[0].safeAreaInsets.bottom
        } else {
            bottomPadding = 0
        }
        if (isReadOnlyModeEnabled()) {
            footer.setReadOnlyMode()
        }
        updateFooterViewCustomUI(footerView: footer)
        footer.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(SpotIm.shouldConversationFooterStartFromBottomAnchor ? view : view.layoutMarginsGuide)
            make.height.equalTo(80.0 + bottomPadding)
        }
    }

    private func updateFooterView() {
        footer.updateColorsAccordingToStyle()
        if let user = SPUserSessionHolder.session.user {
            model.convCommetEntryVM.inputs.configure(user: user)
        }
        updateFooterViewCustomUI(footerView: footer)
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
        articleHeader.OWSnp.updateConstraints { make in
            make.height.equalTo(articleHeaderMaxHeight)
        }
    }
    
    private func removeBannerFromConversation() {
        if model.dataSource.shouldShowBanner {
            tableView.beginUpdates()
            model.dataSource.shouldShowBanner = false
            tableView.deleteSections(IndexSet(integer: model.dataSource.isLoading ? 1 : 0), with: .none)
            tableView.endUpdates()
        }
    }
    
    private func startRealtimeService() {
        let delay = (SPConfigsDataSource.appConfig?.realtime?.startTimeoutMilliseconds ?? 5000) / 1000
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
            self.model.startTypingTracking()
        }
    }

    override func configureEmptyStateView() {
        super.configureEmptyStateView()

        view.bringSubviewToFront(summaryView)
        stateActionView?.OWSnp.makeConstraints({ make in
            make.bottom.equalTo(SpotIm.shouldConversationFooterStartFromBottomAnchor ? view : view.layoutMarginsGuide)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(displayArticleHeader ? articleHeader.OWSnp.bottom : collapsableContainer.OWSnp.bottom)
        })
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
    
    override func heightForRow(at indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0 && model.dataSource.shouldShowBanner) {
            return 280.0
        } else {
            return super.heightForRow(at: indexPath)
        }
    }
}

extension SPMainConversationViewController { // UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && model.dataSource.shouldShowBanner) {
            let adBannerCell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: SPAdBannerCell.self, for: indexPath)

            guard let bannerView = self.bannerView else { return adBannerCell }
            adBannerCell.updateBannerView(bannerView, height: 250.0)
            adBannerCell.delegate = self

            return adBannerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && model.dataSource.shouldShowBanner) {
            if let adBannerCell = cell as? SPAdBannerCell {
                adBannerCell.updateColorsAccordingToStyle()
            }
        } else {
            super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
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

extension SPMainConversationViewController { // UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.dataSource.numberOfRows(in: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return model.dataSource.numberOfSections()
    }
}

extension SPMainConversationViewController: SPAdBannerCellDelegate {
    func hideBanner() {
        guard !model.dataSource.isLoading else { return }
        SPAnalyticsHolder.default.log(event: .fullConversationAdCloseClicked, source: .conversation)
        removeBannerFromConversation()
    }
}

extension SPMainConversationViewController { // SPMainConversationDataSourceDelegate

    override func reload(shouldBeScrolledToTop: Bool) {
        if self.model.areCommentsEmpty(){
            showEmptyStateView()
        } else {
            hideEmptyStateView()
        }

        if shouldBeScrolledToTop {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
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

    func sortingDidTap(_ summaryView: SPConversationSummaryView, sender: UIView) {
        SPAnalyticsHolder.default.log(event: .sortByOpened, source: .conversation)
        showActionSheet(
            title: LocalizationManager.localizedString(key: "Sort by").uppercased(),
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

        updateCollapsableContainerHeightInstantly()
        updateHeaderHeightInstantly()
    }

    /// Instantly updates article header height when scrollView is scrolling
    private func updateCollapsableContainerHeightInstantly() {
        guard shouldDisplayCollapsableContainer else { return }
        if scrollingDirection == .down && collapsableContainer.frame.height == collapsableContainerMaxHeight {
            return
        }
        if lastOffsetY > 0 {
            if (scrollingDirection == .down && lastOffsetY > collapsableContainerMaxHeight) {
                return
            }

            let calculatedHeight = collapsableContainerMaxHeight - lastOffsetY
            let newHeight: CGFloat = max(calculatedHeight, 0)

            collapsableContainerHeightConstraint?.update(offset: newHeight)
        } else {
            collapsableContainerHeightConstraint?.update(offset: collapsableContainerMaxHeight)
        }
    }

    /// Instantly updates article header height when scrollView is scrolling
    private func updateHeaderHeightInstantly() {
        guard isHeaderVisible else { return }

        guard !shouldDisplayCollapsableContainer || collapsableContainer.frame.height == collapsableContainerMinHeight else { return }

        let height: CGFloat
        if lastOffsetY > 0 {
            var calculatedHeight = currentHeightConstant - (lastOffsetY - initialOffsetY)
            if shouldDisplayCollapsableContainer {
                calculatedHeight += (lastOffsetY < collapsableContainerMaxHeight + articleHeaderMaxHeight) ? collapsableContainerMaxHeight : 0
            }

            let newHeight: CGFloat = max(min(calculatedHeight, articleHeaderMaxHeight), articleHeaderMinHeight)

            height = newHeight
        } else {
            height = articleHeaderMaxHeight
        }
        
        articleHeader.OWSnp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }

    /// Updates article header height after scroll view did end actions using `scrollingDirection` property
    private func handleFinalHeaderHeightUpdate(with scrollViewContentOffset: CGPoint) {
        guard scrollingDirection != .static else { return }

        if (shouldDisplayCollapsableContainer) {
            let finaleHeightCommunityGuidelines: CGFloat
            if (scrollViewContentOffset.y <= collapsableContainerMaxHeight * 0.8) {
                finaleHeightCommunityGuidelines = collapsableContainerMaxHeight
            } else {
                finaleHeightCommunityGuidelines = collapsableContainer.frame.height < collapsableContainerMaxHeight * 0.5 ? collapsableContainerMinHeight : collapsableContainerMaxHeight
            }

            collapsableContainerHeightConstraint?.update(offset: finaleHeightCommunityGuidelines)
        }

        if (isHeaderVisible) {
            let finaleHeight: CGFloat = articleHeader.frame.height < articleHeaderMaxHeight * 0.5 ? articleHeaderMinHeight: articleHeaderMaxHeight
            articleHeader.OWSnp.updateConstraints { make in
                make.height.equalTo(finaleHeight)
            }
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        scrollingDirection = .static
    }

    private func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        let scrollViewMaxHeight = scrollView.frame.height + self.articleHeader.frame.height + articleHeaderMaxHeight
        return scrollView.contentSize.height > scrollViewMaxHeight
    }

}

extension SPMainConversationViewController: AdsProviderBannerDelegate {
    func bannerLoaded(bannerView: UIView, adBannerSize: CGSize, adUnitID: String) {
        guard navigationController?.topViewController is SPMainConversationViewController else {
            return
        }
        
//        preparation code for banner in the footer view -
//        need to use adUnitID to handle different banners.
        
//        footerHeightConstraint?.constant = 80.0 + adBannerSize.height + 16.0
//        footer.updateBannerView(bannerView, height: adBannerSize.height)
        
        self.bannerView = bannerView
        
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .banner), source: .conversation)
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonetizationView, .banner), source: .conversation)
        
        if !self.model.dataSource.shouldShowBanner && !self.model.dataSource.isLoading {
            tableView.beginUpdates()
            self.model.dataSource.shouldShowBanner = true
            tableView.insertSections(IndexSet(integer: 0), with: .top)
            tableView.endUpdates()
        }
    }

    func bannerFailedToLoad(error: Error) {
        servicesProvider.logger().log(level: .error, "BannerFailedToLoad - \(error.localizedDescription)")

        SPDefaultFailureReporter.shared.report(error: .monetizationError(.bannerFailedToLoad(source: .mainConversation, error: error)))
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed, .banner), source: .conversation)
    }
}
