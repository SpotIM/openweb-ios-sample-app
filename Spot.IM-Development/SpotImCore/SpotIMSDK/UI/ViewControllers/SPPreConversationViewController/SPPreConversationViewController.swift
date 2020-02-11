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
    
    var adsProvider: AdsProvider? {
        didSet {
            adsProvider?.bannerDelegate = self
            adsProvider?.interstitialDelegate = self
        }
    }
    internal weak var preConversationDelegate: SPPreConversationViewControllerDelegate?

    private lazy var header: SPPreConversationHeaderView = .init()
    private lazy var whatYouThinkView: SPMainConversationFooterView = .init()
    private lazy var footerView: SPPreConversationFooter = .init()
    
    private var tableViewHeightConstraint: NSLayoutConstraint?

    private var checkTableViewHeight: CGFloat = 0
    private let maxSectionCount: Int
    private let readingTracker = SPReadingTracker()
    internal var dataLoaded: (() -> Void)?
    
    internal override var screenTargetType: SPAnScreenTargetType {
        return .preMain
    }

    internal override var messageLineLimit: Int { SPCommonConstants.commentTextLineLimitPreConv }

    private var totalHeight: CGFloat {
        header.frame.height +
        whatYouThinkView.frame.height +
        tableView.frame.height +
        footerView.frame.height
    }

    // MARK: - Overrides
    internal init(model: SPMainConversationModel, numberOfMessagesToShow: Int) {
        self.maxSectionCount = numberOfMessagesToShow < PRE_LOADED_MESSAGES_MAX_NUM ? numberOfMessagesToShow : PRE_LOADED_MESSAGES_MAX_NUM
        super.init(model: model)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SPAnalyticsHolder.default.log(event: .loaded, source: .launcher)

        loadConversation()
        readingTracker.setupTracking(for: view)
        readingTracker.viewDidBecomeVisible = { [weak self] in
            let delay = (SPConfigsDataSource.appConfig?.realtime?.startTimeoutMilliseconds ?? 5000) / 1000
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(delay)) {
                self?.model.startTypingTracking()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateWhatYouThinkView()
        
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.updateTableViewHeightIfNeeded()
        
        if self.model.dataSource.messageCount > 0 {
            self.header.set(commentCount: self.model.dataSource.messageCount.decimalFormatted)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard checkTableViewHeight != totalHeight else { return }
        checkTableViewHeight = totalHeight
        UIView.performWithoutAnimation {
            self.preConversationDelegate?.viewHeightDidChange(to: totalHeight)
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
        view.addSubviews(header, whatYouThinkView, footerView)

        super.setupUI()

        setupHeader()
        setupWhatYouThinkView()
        setupFooterView()

        footerView.setShowMoreCommentsButtonColor(color: .brandColor, withSeparator: true)
    }
    
    private func setupHeader() {
        header.set(title: LocalizationManager.localizedString(key: "Conversation"))

        header.layout {
            $0.top.equal(to: view.topAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: Theme.headerHeight)
        }
    }

    private func setupWhatYouThinkView() {
        view.bringSubviewToFront(whatYouThinkView)
        whatYouThinkView.updateOnlineStatus(.online)
        whatYouThinkView.dropsShadow = false
        whatYouThinkView.showsSeparator = false
        whatYouThinkView.delegate = self
        whatYouThinkView.layout {
            $0.top.equal(to: header.bottomAnchor)
            $0.leading.equal(to: view.leadingAnchor)
            $0.trailing.equal(to: view.trailingAnchor)
            $0.height.equal(to: Theme.whatYouThinkHeight)
        }
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
                        self.stateActionView?.removeFromSuperview()
                        self.stateActionView = nil
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
    
    override func removeSectionAt(index: Int) {
        tableView.reloadData()
    }
    
    override func checkAdsAvailability() {
        guard
            let adsConfig = SPConfigsDataSource.adsConfig,
            let tags = adsConfig.tags
            else { return }
        
        for tag in tags {
            guard let adsId = tag.code else { break }
            switch tag.adType {
            case .banner:
                if model.adsGroup().preConversatioBannerEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize), source: .conversation)
                    
                    adsProvider?.setupAdsBanner(with: adsId, in: self)
                }
            case .interstitial:
                if model.adsGroup().interstitialEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize), source: .conversation)
                    adsProvider?.setupInterstitial(with: adsId)
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
        preConversationDelegate?.showMoreComments(with: model, selectedCommentId: commentId)
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
    
    func showMoreComments() {
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        if let adsProvider = adsProvider,
            model.adsGroup().interstitialEnabled(),
            AdsManager.shouldShowInterstitial(for: model.dataSource.postId),
            adsProvider.showInterstitial(in: self) {
            preConversationDelegate?.showMoreComments(with: model, selectedCommentId: nil)
        } else {
            preConversationDelegate?.showMoreComments(with: model, selectedCommentId: nil)
        }
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
        preConversationDelegate?.showMoreComments(with: model, selectedCommentId: nil)
    }

}

extension SPPreConversationViewController: AdsProviderBannerDelegate {
    func bannerLoaded(adBannerSize: CGSize) {
        guard let bannerView = adsProvider?.bannerView else { return }
        
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized), source: .conversation)
        footerView.updateBannerView(bannerView, height: adBannerSize.height)
    }
    
    func bannerFailedToLoad() {
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed), source: .conversation)
    }
}

extension SPPreConversationViewController: AdsProviderInterstitialDelegate {
    func interstitialLoaded() {
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized), source: .conversation)
    }
    
    func interstitialWillBeShown() {
        AdsManager.willShowInterstitial(for: model.dataSource.postId)
    }
    
    func interstitialDidDismiss() {
        
    }
    
    func interstitialFailedToLoad() {
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitilizeFailed), source: .conversation)
    }
}

extension SPPreConversationViewController: CommentsCounterDelegate {
    func commentsCountDidUpdate(count: Int) {
        self.header.set(commentCount: count.decimalFormatted)
    }
}

private extension SPPreConversationViewController {

    private enum Theme {
        static let whatYouThinkHeight: CGFloat = 64
        static let headerHeight: CGFloat = 50
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
