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

    private lazy var adBannerView: SPAdBannerView = .init()
    private lazy var communityQuestionView = SPCommunityQuestionView()
    private lazy var communityGuidelinesView: SPCommunityGuidelinesView = .init()
    private lazy var header: SPPreConversationHeaderView = .init()
    private lazy var whatYouThinkView: SPMainConversationFooterView = .init()
    private lazy var footerView: SPPreConversationFooter = .init()
        
    private var checkTableViewHeight: CGFloat = 0
    let maxSectionCount: Int
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
        adBannerView.frame.height == 0 ? 0 : Theme.bannerViewMargin
    }
    
    private var totalHeight: CGFloat {
        let result = adBannerView.frame.height +
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
    internal init(model: SPMainConversationModel, numberOfMessagesToShow: Int, adsProvider: AdsProvider, customUIDelegate: OWCustomUIDelegate?) {
        
        self.adsProvider = adsProvider
        // when buttonOnlyMode is on, show no comments
        self.maxSectionCount = SpotIm.buttonOnlyMode.isEnabled() ? 0 :
                            (numberOfMessagesToShow < PRE_LOADED_MESSAGES_MAX_NUM ? numberOfMessagesToShow : PRE_LOADED_MESSAGES_MAX_NUM)
        // button only when numberOfMessagesToShow is 0 OR publisher set mode in SpotIm
        self.isButtonOnlyModeEnabled = (numberOfMessagesToShow == 0 || SpotIm.buttonOnlyMode.isEnabled())
        
        super.init(model: model, customUIDelegate: customUIDelegate)
        adsProvider.bannerDelegate = self
        adsProvider.interstitialDelegate = self
        
        whatYouThinkView.commentCreationEntryView.configure(with: model.preConvCommetEntryVM, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(appMovedToBackground),
        name: UIApplication.willResignActiveNotification,
        object: nil)

        SPAnalyticsHolder.default.log(event: .loaded, source: .launcher)
        
        loadConversation()
        
        self.visibilityTracker.setup(view: view, delegate: self)
        self.bannerVisisilityTracker.setup(view: self.adBannerView, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewFromModel()
        
        if !isButtonOnlyModeEnabled {
            self.updateTableViewData()
        }
        
        self.visibilityTracker.startTracking()
    }
    
    private func updateViewFromModel() {
        if self.model.areCommentsEmpty() && !self.isButtonOnlyModeEnabled {
            self.showEmptyStateView()
        } else {
            self.hideEmptyStateView()
            self.header.set(commentCount: self.model.dataSource.messageCount.decimalFormatted)
            self.footerView.set(commentsCount: self.model.dataSource.messageCount.decimalFormatted)
            self.stateActionView?.removeFromSuperview()
            self.stateActionView = nil
        }
        if let user = SPUserSessionHolder.session.user {
            model.preConvCommetEntryVM.inputs.configure(user: user)
        }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        model.currentBindedVC = .preConversation
    }
    
    @objc
    public func reactNativeShowMoreComments() {
        SPAnalyticsHolder.default.log(event: .loadMoreComments, source: .conversation)
        preConversationDelegate?.showMoreComments(with: model, selectedCommentId: nil)
    }
    
    // Handle dark mode \ light mode change
    override func updateColorsAccordingToStyle() {
        super.updateColorsAccordingToStyle()
        self.view.backgroundColor = .spBackground0
        self.tableView.backgroundColor = .spBackground0
        self.adBannerView.updateColorsAccordingToStyle()
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
        if (tableView.frame.size.height != tableView.contentSize.height) {
            tableView.OWSnp.updateConstraints { make in
                make.height.equalTo(tableView.contentSize.height)
            }
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Private methods

    override func setupUI() {
        view.addSubviews(adBannerView, footerView)
        
        setupBannerView()
        
        if SpotIm.buttonOnlyMode != .withoutTitle {
            view.addSubview(header)
            setupHeaderView()
        }
        
        if !isButtonOnlyModeEnabled {
            view.addSubviews(communityGuidelinesView, communityQuestionView, whatYouThinkView)
            super.setupUI()
            configureCommunityQuestionView()
            setupCommunityGuidelinesView()
            setupWhatYouThinkView()
        }

        setupFooterView()
        footerView.setShowMoreCommentsButtonColor(color: .brandColor, withSeparator: true)
    }
    
    private func updateTableViewData() {
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.updateTableViewHeightIfNeeded()
    }
    
    private func setupBannerView() {
        adBannerView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }

    private func setupHeaderView() {
        header.set(title: LocalizationManager.localizedString(key: "Conversation"))
        header.delegate = self
        header.configure(onlineViewingUsersVM: model.onlineViewingUsersPreConversationVM)
        let headerHeight = SpotIm.buttonOnlyMode == .withoutTitle ? 0 : Theme.headerHeight
        
        header.OWSnp.makeConstraints { make in
            make.top.equalTo(adBannerView.OWSnp.bottom).offset(actualBannerMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(headerHeight)
        }
        
        if SpotIm.buttonOnlyMode == .withoutTitle {
            header.isHidden = true
        }
    }
    
    private func configureCommunityQuestionView() {
        communityQuestionView.clipsToBounds = true
        updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
        
        communityQuestionView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityGuidelinesView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func updateCommunityQuestion(communityQuestionText: String?) {
        // hide when no community question or in on button mode
        if let communityQuestionText = communityQuestionText, communityQuestionText.length > 0, !isButtonOnlyModeEnabled {
            communityQuestionView.setupCommunityQuestion(with: communityQuestionText)
            communityQuestionView.clipsToBounds = true
            communityQuestionView.setupPreConversationConstraints()
            communityGuidelinesView.setSeperatorVisible(isVisible: false)
        } else {
            communityQuestionView.isHidden = true
            communityQuestionView.OWSnp.makeConstraints { make in
                make.height.equalTo(0.0)
            }
            communityGuidelinesView.setSeperatorVisible(isVisible: true)
        }
        updateCommunityQuestionCustomUI(communityQuestionView: communityQuestionView)
    }
    
    private func setupCommunityGuidelinesView() {
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.equalTo(header.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        
        // hide when no community guidelines or in button only mode
        if let htmlString = getCommunityGuidelinesTextIfExists() {
            communityGuidelinesHtmlString = htmlString
            communityGuidelinesView.delegate = self
            communityGuidelinesView.setHtmlText(htmlString: htmlString)
            communityGuidelinesView.setupPreConversationConstraints()
        } else {
            communityGuidelinesView.isHidden = true
            communityGuidelinesView.OWSnp.makeConstraints { make in
                make.height.equalTo(0.0)
            }
        }
    }

    private func setupWhatYouThinkView() {
        view.bringSubviewToFront(whatYouThinkView)
        whatYouThinkView.dropsShadow = false
        whatYouThinkView.showsSeparator = false
        whatYouThinkView.OWSnp.makeConstraints { make in
            make.top.equalTo(communityQuestionView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Theme.whatYouThinkHeight)
        }
        self.updateFooterViewCustomUI(footerView: self.whatYouThinkView)
    }
    
    override func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.OWSnp.makeConstraints { make in
            make.top.equalTo(whatYouThinkView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }

    private func setupFooterView() {
        view.bringSubviewToFront(footerView)
        footerView.delegate = self
        footerView.set(buttonOnlyMode: isButtonOnlyModeEnabled)
        
        let topConstraint = isButtonOnlyModeEnabled ? (SpotIm.buttonOnlyMode == .withoutTitle ? adBannerView.OWSnp.bottom : header.OWSnp.bottom) :  tableView.OWSnp.bottom
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(topConstraint)
            make.leading.trailing.equalToSuperview()
        }
    }

    private func loadConversation() {
        guard !model.dataSource.isLoading else { return }

        model.dataSource.conversation(
            model.getInitialSortMode(),
            page: .first,
            loadingStarted: {},
            completion: { [weak self] (success, error) in
                guard let self = self else { return }
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
                    self.servicesProvider.logger().log(level: .error, "Load conversation request type is not `success`")
                } else {
                    self.checkAdsAvailability()
                    
                    SPAnalyticsHolder.default.totalComments = self.model.dataSource.messageCount
                    SPAnalyticsHolder.default.log(event: .loaded, source: .conversation)
                    
                    self.updateViewFromModel()
                }
                
                if !self.isButtonOnlyModeEnabled {
                    self.updateCommunityQuestion(communityQuestionText: self.getCommunityQuestion())
                    if (self.isReadOnlyModeEnabled()) {
                        self.whatYouThinkView.setReadOnlyMode(isPreConversation: true)
                        self.updateFooterViewCustomUI(footerView: self.whatYouThinkView, isPreConversation: true)
                    }
                    self.updateTableViewData()
                }
                
                self.dataLoaded?()
            }
        )
    }

    override func configureEmptyStateView() {
        super.configureEmptyStateView()
        stateActionView?.backgroundColor = .white
        
        stateActionView?.OWSnp.makeConstraints({ make in
            make.top.equalTo(header.OWSnp.bottom).offset(10.0)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(footerView.OWSnp.top)
        })
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

    override func showEmptyStateView() {
        // Here we specifically showing call to action text instead of the default empty state
        self.stateActionView?.removeFromSuperview()
        self.stateActionView = nil
        let callToAction = LocalizationManager.localizedString(key: "Be the first to comment")
        footerView.hideShowMoreCommentsButton()
        model.preConvCommetEntryVM.inputs.configure(ctaText: callToAction)
    }
    
    override func hideEmptyStateView() {
        self.stateActionView?.removeFromSuperview()
        self.stateActionView = nil
        
        footerView.showShowMoreCommentsButton()
        let callToAction = LocalizationManager.localizedString(key: "What do you think?")
        model.preConvCommetEntryVM.inputs.configure(ctaText: callToAction)
    }

    override func showErrorStateView() {
        super.showErrorStateView()
        footerView.hideShowMoreCommentsButton()
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
                       lineLimit: messageLineLimit,
                       isReadOnlyMode: isReadOnlyModeEnabled(),
                       windowWidth: self.view.window?.frame.width)
        }
    }
    
    override func reloadAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
        updateTableViewHeightIfNeeded()
    }
    
    override func removeSectionAt(index: Int) {
        tableView.reloadData()
    }
    
    override func setupAds(for tags: [SPAdsConfigurationTag]) {
        for tag in tags {
            guard let adsId = tag.code else { break }
            switch tag.adType {
            case .banner:
                if model.adsGroup().preConversatioBannerEnabled() {
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineMonitizationLoad, .banner), source: .conversation)
                    SPAnalyticsHolder.default.log(event: .engineStatus(.engineWillInitialize, .banner), source: .conversation)
                    
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
                servicesProvider.logger().log(level: .medium, "Did not showed interstitial")
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
        self.updateTableViewData()
    }
   
    @objc
    override func indicationViewClicked() {
        guard model.realtimeViewType == .blitz else { return }
        super.indicationViewClicked()
        self.moveToFullConversation(selectedCommentId: nil)
    }
    
    @objc
    private func appMovedToBackground() {
        SPAnalyticsHolder.default.log(event: .appClosed, source: .mainPage)
    }
    
    @objc override func overrideUserInterfaceStyleDidChange() {
        super.overrideUserInterfaceStyleDidChange()
        self.tableView.reloadData()
    }
}

// MARK: - Extensions

extension SPPreConversationViewController { // UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = model.dataSource.numberOfSections()
        return numberOfSections < maxSectionCount ? numberOfSections : maxSectionCount
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapComment(with: indexPath)
    }
}

extension SPPreConversationViewController: SPPreConversationHeaderViewDelegate {
    func updateHeaderCustomUI(titleLabel: UILabel, counterLabel: UILabel) {
        customUIDelegate?.customizePreConversationHeader(titleLabel: titleLabel, counterLabel: counterLabel)
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
    func bannerLoaded(bannerView: UIView, adBannerSize: CGSize, adUnitID: String) {
        SPAnalyticsHolder.default.log(event: .engineStatus(.engineInitialized, .banner), source: .conversation)
 
        adBannerView.OWSnp.makeConstraints { make in
            make.height.equalTo(adBannerSize.height)
        }
        
        adBannerView.update(bannerView, height: adBannerSize.height)
        
        bannerVisisilityTracker.startTracking()
    }
    
    func bannerFailedToLoad(error: Error) {
        servicesProvider.logger().log(level: .error, "error bannerFailedToLoad - \(error.localizedDescription)")
        SPDefaultFailureReporter.shared.report(error: .monetizationError(.bannerFailedToLoad(source: .preConversation, error: error)))
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
        SPDefaultFailureReporter.shared.report(error: .monetizationError(.interstitialFailedToLoad(error: error)))
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
        
        if view == self.adBannerView {
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

internal protocol SPPreConversationViewControllerDelegate: AnyObject {
    func showMoreComments(with dataModel: SPMainConversationModel, selectedCommentId: String?)
    func showTerms()
    func showPrivacy()
    func showAddSpotIM()
    func viewHeightDidChange(to newValue: CGFloat)
}
