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

final class SPMainConversationViewController: SPBaseConversationViewController,
    UserAuthFlowDelegateContainable,
    UserPresentable {
    
    enum ScrollingDirection {
        case up, down, `static`
    }
    weak var userAuthFlowDelegate: UserAuthFlowDelegate?
    var commentIdToShowOnOpen: String?
    
    var adsProvider: AdsProvider? {
        didSet {
            adsProvider?.delegate = self
        }
    }
        
    private let sortView = SPConversationSummaryView()

    private lazy var refreshControl = UIRefreshControl()
    private lazy var tableHeader = SPArticleHeader()
    private lazy var footer = SPMainConversationFooterView()
    private var authHandler: AuthenticationHandler?
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

    private var scrollingDirection: ScrollingDirection = .static {
        didSet {
            if oldValue != scrollingDirection {
                currentHeightConstant = headerHeightConstraint?.constant ?? 0.0
                initialOffsetY = lastOffsetY
            }
        }
    }

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SPAnalyticsHolder.default.pageViewId != SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId {
            SPAnalyticsHolder.default.log(event: .mainViewed, source: .conversation)
            SPAnalyticsHolder.default.lastRecordedMainViewedPageViewId = SPAnalyticsHolder.default.pageViewId
        }
        checkAdsAvailability()
        updateHeaderUI()
        configureModelHandlers()
        setupUserIconHandler()
    
        tableHeader.setAuthor(model.dataSource.conversationPublisherName)

        // for case when there are no data passed from the pre-conversation screen
        if model.dataSource.messageCount ?? 0 <= 0 {
            reloadFullConversation()
        } else {
            updateFooterView()
            sortView.updateCommentsLabel(model.dataSource.messageCount ?? 0)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
        model.delegates.add(delegate: self)
        model.commentsCounterDelegates.add(delegate: self)
        
        totalTypingCountDidUpdate(count: model.typingCount())
        if model.liveTotalCommentsCount() > 0 {
            sortView.updateCommentsLabel(model.liveTotalCommentsCount())
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
    
    func userDidSignInHandler() -> AuthenticationHandler? {
        authHandler = AuthenticationHandler()
        authHandler?.authHandler = { [weak self] isAuthenticated in
            self?.reloadFullConversation()
        }
        
        return authHandler
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
                self.reloadFullConversation()
            }
        }
    }
    
    @objc
    private func reloadFullConversation() {
        guard !model.dataSource.isLoading else { return }

        let mode = model.sortOption
        model.dataSource.conversation(
            mode,
            page: .first,
            completion: { [weak self] (success, error) in
                guard let self = self else { return }
                
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
                    let messageCount = self.model.dataSource.messageCount
                    SPAnalyticsHolder.default.totalComments = messageCount
                    self.sortView.updateCommentsLabel(messageCount ?? 0)
                    
                    if self.model.areCommentsEmpty() {
                        self.showEmptyStateView()
                    } else {
                        self.stateActionView?.removeFromSuperview()
                        self.stateActionView = nil
                        self.tableView.scrollRectToVisible(.init(x: 0, y: 0 , width: 1, height: 1), animated: true)
                    }
                }
                self.tableView.reloadData()
                self.updateHeaderUI()
                self.updateFooterView()
            }
        )
    }

    private func loadCommentsNextPage() {
        guard !model.dataSource.isLoading else { return }
        
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        let mode = model.sortOption
        model.dataSource.comments(
            mode,
            page: .next,
            loadingStarted: {
                // showing loader section
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
                    self.sortView.updateCommentsLabel(self.model.dataSource.messageCount ?? 0)
                }
                
                self.tableView.reloadData()
            }
        )
    }

    override func setupUI() {
        view.addSubviews(footer, sortView, tableHeader)

        super.setupUI()
    
        setupSortView()
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
            $0.top.equal(to: view.topAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.height.equal(to: 44.0)
        }
    }
    
    private func configureTableHeaderView() {
        view.bringSubviewToFront(tableHeader)
        tableHeader.clipsToBounds = true
        tableHeader.layout {
            $0.top.equal(to: sortView.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            headerHeightConstraint = $0.height.equal(to: 0.0)
        }
    }
    
    override func setupTableView() {
        super.setupTableView()

        tableView.layout {
            $0.top.equal(to: tableHeader.bottomAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.bottom.equal(to: footer.topAnchor)
        }
    }

    override func checkAdsAvailability() {
        guard
            let adsConfig = SPConfigsDataSource.adsConfig,
            let tags = adsConfig.tags,
            model.adsGroup() != nil
            else { return }
        
        for tag in tags {
            guard let adsId = tag.code else { break }
            switch tag.adType {
            case .banner:
                adsProvider?.setupAdsBanner(with: adsId, in: self)
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
        refreshControl.addTarget(self, action: #selector(reloadFullConversation), for: .valueChanged)
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
        if model.dataSource.thumbnailUrl != nil ||
            model.dataSource.conversationTitle != nil {
//            tableView.contentInset = UIEdgeInsets(top: 85, left: 0, bottom: 0, right: 0)
            isHeaderVisible = true
            headerHeightConstraint?.constant = articleHeaderMaxHeight
            tableHeader.setAuthor(model.dataSource.conversationPublisherName)
            tableHeader.setImage(with: model.dataSource.thumbnailUrl)
            tableHeader.setTitle(model.dataSource.conversationTitle)
        }
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
            self?.reloadFullConversation()
        }
    }

    override func configureNoInternetAction() -> ConversationStateAction {
        return { [weak self] in
            self?.showLoader()
            self?.reloadFullConversation()
        }
    }
    
    override func isLastSection(with section: Int) -> Bool {
        return model.dataSource.numberOfSections() == section + 1
    }
}

extension SPMainConversationViewController { // UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        loadNextPageIfNeeded(forRowAt: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleArticleHeight(with: scrollView.contentOffset)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleFinalHeaderHeightUpdate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
        if !decelerate {
            handleFinalHeaderHeightUpdate()
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
        sortView.updateCommentsLabel(model.dataSource.messageCount ?? 0)
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
        let currentOffsetY = scrollViewContentOffset.y + articleHeaderMaxHeight
        if isDragging {
            scrollingDirection = currentOffsetY > lastOffsetY ? .up : .down
        }
        lastOffsetY = currentOffsetY
        updateHeaderHeightInstantly()
            
    }
    
    /// Instantly updates article header height when scrollView is scrolling
    private func updateHeaderHeightInstantly() {
        guard isHeaderVisible else { return }
        
        if lastOffsetY > 0 {
            let calculatedHeight = currentHeightConstant - (lastOffsetY - initialOffsetY)
            let newHeight: CGFloat = calculatedHeight > articleHeaderMaxHeight
                ? articleHeaderMaxHeight
                : (calculatedHeight < articleHeaderMinHeight) ? articleHeaderMinHeight : calculatedHeight
            
            headerHeightConstraint?.constant = newHeight
        } else {
            headerHeightConstraint?.constant = articleHeaderMaxHeight
        }
    }
    
    /// Updates article header height after scroll view did end actions using `scrollingDirection` property
    private func handleFinalHeaderHeightUpdate() {
        guard scrollingDirection != .static, isHeaderVisible else { return }
        let finaleHeight: CGFloat = scrollingDirection == .up
            ? (lastOffsetY <= articleHeaderMinHeight ? articleHeaderMaxHeight : articleHeaderMinHeight)
            : articleHeaderMaxHeight
        headerHeightConstraint?.constant = finaleHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        scrollingDirection = .static
    }
}

extension SPMainConversationViewController: AdsProviderDelegate {
    
    func bannerAdDidLoad(adBannerSize: CGSize) {
        guard
            let bannerView = adsProvider?.bannerView,
            model.adsGroup() == .third
            else { return }
        
        footerHeightConstraint?.constant = 80.0 + adBannerSize.height + 16.0
        footer.updateBannerView(bannerView, height: adBannerSize.height)
    }
    
    func interstitialWillBeShown() {}
    
    func interstitialDidDismiss() {}
    
}

extension SPMainConversationViewController: CommentsCounterDelegate {
    func commentsCountDidUpdate(count: Int) {
        self.sortView.updateCommentsLabel(count)
    }
}
