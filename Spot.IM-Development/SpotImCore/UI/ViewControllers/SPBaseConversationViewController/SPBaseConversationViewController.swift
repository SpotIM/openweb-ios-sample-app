//
//  SPBaseConversationViewController.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 19/08/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

internal class SPBaseConversationViewController: SPBaseViewController, OWAlertPresentable, OWLoaderPresentable, OWUserAuthFlowDelegateContainable {

    weak var userAuthFlowDelegate: OWUserAuthFlowDelegate?
    private var authHandler: OWAuthenticationHandler?

    // If we are using inheritance let's at least take advantage of it, that's why not private
    let servicesProvider: OWSharedServicesProviding

    weak var webPageDelegate: SPSafariWebPageDelegate?

    internal lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
            .enforceSemanticAttribute()
            .backgroundColor(.spBackground0)
            .separatorStyle(.none)
            .dataSource(self)
            .delegate(self)

        tableView.register(cellClass: SPReplyCell.self)
        tableView.register(cellClass: SPCommentCell.self)
        tableView.register(cellClass: SPLoaderCell.self)
        tableView.register(cellClass: SPAdBannerCell.self)

        return tableView
    }()

    internal weak var delegate: SPCommentsCreationDelegate?
    internal var stateActionView: SPEmptyConversationActionView?

    let activityIndicator: SPLoaderView = SPLoaderView()
    internal let model: SPMainConversationModel

    typealias ConversationStateAction = () -> Void

    internal var screenTargetType: SPAnScreenTargetType {
        fatalError("Implement in subclass")
    }
    internal var didCheckAdsAvailability = false
    internal var messageLineLimit: Int { SPCommonConstants.commentTextLineLimitMainConv }

    internal var typingIndicationView: TotalTypingIndicationView?
    private var typingViewBottomConstraint: OWConstraint?
    private var typingViewCenterConstraint: OWConstraint?
    private var typingViewCenterCurrentOffset: CGFloat?

    // MARK: - Internal methods

    internal init(model: SPMainConversationModel, customUIDelegate: OWCustomUIDelegate? = nil,
                  servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.model = model

        self.servicesProvider = servicesProvider

        super.init(customUIDelegate: customUIDelegate)
        self.model.openUserProfileDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false
        setupUI()
        addLongTouchHandler()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        model.dataSource.delegate = self
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configureBaseModelHandlers()

    }

    override func viewDidChangeWindowSize() {
        self.tableView.reloadData()
    }

    func didStartSignInFlow() {
        // Override this method in your VC to handle
    }

    func userDidSignInHandler() -> OWAuthenticationHandler? {
        authHandler = OWAuthenticationHandler()
        authHandler?.authHandler = { [weak self] isAuthenticated in
            self?.handleUserSignedIn(isAuthenticated: isAuthenticated)
        }

        return authHandler
    }

    func handleUserSignedIn(isAuthenticated: Bool) {
        // Override this method in your VC to handle
        self.reloadConversation()
    }

    @objc
    internal func reloadConversation(showLoader: Bool = true) {
        guard !model.dataSource.isLoading else { return }
        if showLoader {
            self.showLoader()
        }
        let mode = model.sortOption
        servicesProvider.logger().log(level: .verbose, "FirstComment: Calling conversation API")
        model.dataSource.conversation(
            mode,
            page: .first,
            completion: { [weak self] (success, error) in
                guard let self = self else { return }
                self.servicesProvider.logger().log(level: .verbose, "FirstComment: API did finish with \(success)")
                self.handleConversationReloaded(success: success, error: error)
            }
        )
    }

    func handleConversationReloaded(success: Bool, error: SPNetworkError?) {
        // Override this method in your VC to handle
    }

    internal func updateCommunityQuestionCustomUI(communityQuestionView: SPCommunityQuestionView) {
        guard let customUIDelegate = self.customUIDelegate else { return }
        communityQuestionView.customizeCommunityQuestion(
            customUIDelegate: customUIDelegate,
            source: runtimeSource
        )
    }
    internal func updateFooterViewCustomUI(footerView: SPMainConversationFooterView, isPreConversation: Bool = false) {
        guard let customUIDelegate = self.customUIDelegate else { return }
        footerView.handleUICustomizations(customUIDelegate: customUIDelegate, isPreConversation: isPreConversation)
    }

    internal func getCommunityGuidelinesTextIfExists() -> String? {
        guard let conversationConfig = SPConfigsDataSource.appConfig?.conversation,
              conversationConfig.communityGuidelinesEnabled == true,
              let communityGuidelinesTitle = conversationConfig.communityGuidelinesTitle else {
            return nil
        }
        return getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelinesTitle)
    }

    internal func getCommunityQuestion() -> String? {
        return model.dataSource.communityQuestion
    }

    internal func isReadOnlyModeEnabled() -> Bool {
        return model.isReadOnlyMode()
    }

    private func getCommunityGuidelinesHtmlString(communityGuidelinesTitle: SPCommunityGuidelinesTitle) -> String {
        var htmlString = communityGuidelinesTitle.value

        // remove <p> and </p> tags to control the text height by the sdk
        htmlString = htmlString.replacingOccurrences(of: "<p>", with: "")
        htmlString = htmlString.replacingOccurrences(of: "</p>", with: "")

        return htmlString
    }

    private func myUserAvatarDidTap() {
        guard let user = SPUserSessionHolder.session.user,
              let policyForceRegister = SPConfigsDataSource.appConfig?.initialization?.policyForceRegister else {
            return
        }
        if (user.registered || !policyForceRegister) {
            model.authorTapped.onNext((
                user: user,
                commentId: nil,
                isTappedOnAvatar: true
            ))
        } else {
            self.startLoginFlow()
        }
    }

    internal func setupUI() {
        view.addSubview(tableView)
        view.sendSubviewToBack(tableView)
        setupTableView()
    }

    internal func setupTableView() {
        fatalError("For now Let's override this function, the plan is to remove this base class completely")
    }

    func configureEmptyStateView() {
        guard stateActionView == nil else { return }

        stateActionView = createEmptyConversationActionView()
        view.addSubview(stateActionView!)
    }

    internal func cellData(for indexPath: IndexPath) -> CommentViewModel? {
        return model.dataSource.cellData(for: indexPath)
    }

    internal func cellDataHeight(for indexPath: IndexPath) -> CGFloat {
        let isLast = model.dataSource.numberOfRows(in: indexPath.section) == indexPath.row + 1
        let cellData = model.dataSource.cellData(for: indexPath)

        return cellData.height(with: messageLineLimit, isLastInSection: isLast)
    }

    internal func showErrorStateView() {
        configureEmptyStateView()
        let errorAction = configureErrorAction()
        stateActionView?.configure(
            actionModel: EmptyActionDataModel(
                actionMessage: LocalizationManager.localizedString(key: "We are unable to load comments\nright now."),
                actionIcon: UIImage(spNamed: "emptyCommentsIcon", supportDarkMode: true)!,
                actionButtonTitle: LocalizationManager.localizedString(key: "Retry"),
                action: errorAction)
        )
    }

    func hideEmptyStateView() {
        self.stateActionView?.removeFromSuperview()
        self.stateActionView = nil
    }

    internal func showEmptyStateView() {
        configureEmptyStateView()
        let actionMessage: String
        let actionIcon: UIImage
        var actionButtonTitle: String? = nil
        var action: EmptyActionDataModel.Action? = nil
        if (isReadOnlyModeEnabled()) {
            actionMessage = LocalizationManager.localizedString(key: "Commenting on this article has ended")
            actionIcon = UIImage(spNamed: "emptyCommentsReadOnlyIcon", supportDarkMode: true)!
        } else {
            actionMessage = LocalizationManager.localizedString(key: "Be the first to comment")
            actionIcon = UIImage(spNamed: "emptyCommentsIcon", supportDarkMode: true)!
            actionButtonTitle = LocalizationManager.localizedString(key: "Write a Comment")
            action = { [weak self] in
                guard let self = self, let delegate = self.delegate else { return }
                self.logCreationOpen(with: .comment)
                delegate.createComment(with: self.model)
            }
        }
        stateActionView?.configure(
            actionModel: EmptyActionDataModel(
                actionMessage: actionMessage,
                actionIcon: actionIcon,
                actionButtonTitle: actionButtonTitle,
                action: action
            )
        )
        if isReadOnlyModeEnabled(), let label = stateActionView?.messageLabel {
            customUIDelegate?.customizeView(.emptyStateReadOnlyLabel(label: label), source: runtimeSource)
        }
    }

    internal func updateEmptyStateViewAccordingToStyle() {
        stateActionView?.updateColorsAccordingToStyle()
    }

    func configureErrorAction() -> ConversationStateAction {
        fatalError("Implement in subclass")
    }

    func configureNoInternetAction() -> ConversationStateAction {
        fatalError("Implement in subclass")
    }

    func createEmptyConversationActionView() -> SPEmptyConversationActionView {
        return SPEmptyConversationActionView()
    }

    private func addLongTouchHandler() {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longGesture.minimumPressDuration = 0.5
        longGesture.delaysTouchesBegan = true
        tableView.addGestureRecognizer(longGesture)
    }

    private func configureBaseModelHandlers() {
        model.commentsActionDelegate = self
    }

    private func showNoInternetStateView() {
        configureEmptyStateView()
        let noInternetAction = configureNoInternetAction()
        stateActionView?.configure(
            actionModel: EmptyActionDataModel(
                actionMessage: LocalizationManager.localizedString(key: "Whoops! Looks like we’re\nexperiencing some\nconnectivity issues."),
                actionIcon: UIImage(spNamed: "emptyCommentsIcon", supportDarkMode: true)!,
                actionButtonTitle: LocalizationManager.localizedString(key: "Retry"),
                action: noInternetAction
            )
        )
    }

    internal func isLastSection(with section: Int) -> Bool {
        fatalError("Implement in subclass")
    }

    internal func shouldShowLoader(forRowAt indexPath: IndexPath) -> Bool {
        fatalError("Implement in subclass")
    }

    internal func presentErrorView(error: SPNetworkError) {
        switch error {
        case .noInternet:
            showNoInternetStateView()
        default:
            showErrorStateView()
        }
    }

    internal func removeSectionAt(index: Int) {
        tableView.deleteSections(IndexSet(integer: index), with: .automatic)
        if index == 0 {
            tableView.reloadData()
        }
    }

    func checkAdsAvailability() {
        guard
            !didCheckAdsAvailability,
            !disableAdsForUser(),
            let adsConfig = SPConfigsDataSource.adsConfig,
            let tags = adsConfig.tags
            else { return }
        didCheckAdsAvailability = true
        setupAds(for: tags)
    }

    func setupAds(for tags: [SPAdsConfigurationTag]) {
        // Override this method in your VC if you need to configure advertisement
    }

    func disableAdsForUser() -> Bool {
        guard let config = SPConfigsDataSource.appConfig,
              let disableAdsForSubscribers = config.mobileSdk.disableAdsForSubscribers,
              let user = SPUserSessionHolder.session.user,
              let ssoData = user.ssoData
        else { return false }
        return disableAdsForSubscribers && ssoData.isSubscriber
    }

    internal func handleCommentSizeChange() {
        // implement in subclasses if needed
    }

    private func logCreationOpen(with creationType: SPAnItemType, parentId: String? = nil) {
        SPAnalyticsHolder.default.log(
            event: .createMessageClicked(
                itemType: creationType,
                targetType: screenTargetType,
                relatedMessage: parentId
            ),
            source: .conversation
        )
    }

    @objc
    private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }

        let touchInTableView = gestureRecognizer.location(in: tableView)

        guard let indexPath = tableView.indexPathForRow(at: touchInTableView),
            let cell = tableView.cellForRow(at: indexPath),
            let cellWithMessage = cell as? MessageItemContainable
            else {
                return
        }

        let touchInCell = tableView.convert(touchInTableView, to: cell)

        guard cellWithMessage.containsChatItem(at: touchInCell) else { return }

        model.copyCommentText(at: indexPath)

        showToast(message: LocalizationManager.localizedString(key: "Text copied to clipboard"),
                  hideAfter: 0.7)

    }

    public func heightForRow(at indexPath: IndexPath) -> CGFloat {
        if shouldShowLoader(forRowAt: indexPath) {
            return 50.0
        } else {
            let isIndexPath: Bool = indexPath == IndexPath(row: 0, section: 0)
            let isComment: Bool = indexPath.row == 0
            let headerSpacing: CGFloat = !isIndexPath && isComment ? Theme.separatorHeight : 0.0
            return cellDataHeight(for: indexPath) + headerSpacing
        }
    }

    private func handleTypingIndicationViewUpdate(typingCount: Int, newCommentsCount: Int, shouldShowBlitz: Bool) {
        if typingCount <= 0 && !shouldShowBlitz {
            hideTypingIndicationView()
        } else if let typingIndicationView = typingIndicationView {
            typingIndicationView.setCount(count: shouldShowBlitz ? newCommentsCount : typingCount, isBlitz: shouldShowBlitz)
        } else {
            createAndShowTypingIndicationView()
            typingIndicationView?.setCount(count: shouldShowBlitz ? newCommentsCount : typingCount, isBlitz: shouldShowBlitz)
        }
    }
}

private extension SPBaseConversationViewController {

    private enum Theme {
        static let separatorHeight: CGFloat = 7
    }
}

extension SPBaseConversationViewController: TotalTypingIndicationViewDelegate {
    @objc
    func indicationViewClicked() {
        guard model.realtimeViewType == .blitz else { return }
        // add new messages to the top of conversation
        model.addNewCommentsToConversation()
        model.clearNewMessagesCache()
        self.handleConversationReloaded(success: true, error: nil)
        model.setReltime(viewType: .typing)
    }

    func horisontalPositionChangeDidEnd() {
        guard
            let currentCenterConstant = typingViewCenterCurrentOffset
            else { return }

        if currentCenterConstant > (view.bounds.width / 4) ||
            currentCenterConstant < -(view.bounds.width / 4) {
            model.stopTypingTracking()
        } else {
            returnTypingViewToTheCenter()
        }
    }

    func horisontalPositionDidChange(transition: CGFloat) {
        typingViewCenterCurrentOffset = transition
        typingViewCenterConstraint?.update(offset: transition)
    }

    private func dismissTypingViewToTheSide() {
        guard
            let currentCenterConstant = typingViewCenterCurrentOffset
            else { return }

        typingViewCenterConstraint?.update(offset: currentCenterConstant > 0 ? view.bounds.width : -view.bounds.width)
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.typingIndicationView?.removeFromSuperview()
            self.typingIndicationView = nil
            self.typingViewCenterCurrentOffset = 0
        })
    }

    private func returnTypingViewToTheCenter() {
        typingViewCenterConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func hideTypingIndicationView() {
        typingViewBottomConstraint?.update(offset: 100.0)
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.typingIndicationView?.alpha = 0
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.typingIndicationView?.removeFromSuperview()
                self.typingIndicationView = nil
            }
        )
    }

    private func createAndShowTypingIndicationView() {
        typingIndicationView = TotalTypingIndicationView()
        typingIndicationView?.delegate = self
        typingIndicationView?.alpha = 0
        view.insertSubview(typingIndicationView!, aboveSubview: tableView)

        typingIndicationView?.OWSnp.makeConstraints({ make in
            typingViewBottomConstraint = make.bottom.equalTo(tableView).offset(100.0).constraint
            typingViewCenterConstraint = make.centerX.equalToSuperview().constraint
            typingViewCenterCurrentOffset = 0.0
            make.height.equalTo(34.0)
        })
        view.layoutIfNeeded()

        typingViewBottomConstraint?.update(offset: -25.0)
        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.5,
            animations: {
                self.typingIndicationView?.alpha = 1
                self.view.layoutIfNeeded()
            }
        )
    }
}

extension SPBaseConversationViewController: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // Implement in subclass
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 0 // Implement in subclass
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldShowLoader(forRowAt: indexPath) {
            let loaderCell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: SPLoaderCell.self, for: indexPath)
            loaderCell.startAnimating()

            return loaderCell
        } else if indexPath.row == 0 {
            let commentCell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: SPCommentCell.self, for: indexPath)
            if let data = cellData(for: indexPath) {
                commentCell.setup(
                    with: data,
                    shouldShowHeader: indexPath.section != 0,
                    minimumVisibleReplies: model.dataSource.minVisibleReplies,
                    lineLimit: messageLineLimit,
                    isReadOnlyMode: isReadOnlyModeEnabled(),
                    windowWidth: self.view.window?.frame.width
                )
            }
            commentCell.delegate = self

            return commentCell
        } else {
            let replyCell = tableView.dequeueReusableCellAndReigsterIfNeeded(cellClass: SPReplyCell.self, for: indexPath)
            replyCell.configure(
                with: model.dataSource.cellData(for: indexPath),
                lineLimit: messageLineLimit,
                isReadOnlyMode: isReadOnlyModeEnabled(),
                windowWidth: self.view.window?.frame.width
            )
            replyCell.delegate = self

            return replyCell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let commentCell = cell as? SPCommentCell {
            commentCell.updateColorsAccordingToStyle()
        }
        if let replyCell = cell as? SPReplyCell {
            replyCell.updateColorsAccordingToStyle()
        }
    }

}

extension SPBaseConversationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    // swiftlint:disable:next line_length
    // https://stackoverflow.com/questions/42246153/returning-cgfloat-leastnormalmagnitude-for-uitableview-section-header-causes-cra
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 0.01
        } else {
            return 1.01
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if #available(iOS 11.0, *) {
            return 0.01
        } else {
            return 1.01
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // required to have correct section separator in older versions of iOS
        return 0.01
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // required to have correct section separator in older versions of iOS
        return 0.01
    }
}

extension SPBaseConversationViewController: SPMainConversationDataSourceDelegate {
    @objc
    func reloadAt(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    @objc
    func reload(shouldBeScrolledToTop: Bool) {
        if shouldBeScrolledToTop {
            tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
        tableView.reloadData()
    }

    @objc
    func reload(scrollToIndexPath: IndexPath?) {}

    func dataSource(dataSource: SPMainConversationDataSource, didInsertRowsAt indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: .automatic)
    }

    func dataSource(dataSource: SPMainConversationDataSource, didInsertSectionsAt indexes: [Int]) {
        CATransaction.begin()
        tableView.beginUpdates()
        CATransaction.setCompletionBlock {
            self.tableView.reloadData()
        }

        // Part of the reason why inheritance is crap.. We won't have such things once we will refactor the UI layer
        if let preConversation = self as? SPPreConversationViewController {
            // In the pre conversation we can add section only if we didn't exceed the max number of sections (which return in the table view number of sections delegate)
            let currentSections = dataSource.numberOfSections()
            if currentSections <= preConversation.maxSectionCount {
                tableView.insertSections(IndexSet(indexes), with: .top)
            }
        } else {
            // Full conversation
            tableView.insertSections(IndexSet(indexes), with: .top)
        }

        tableView.endUpdates()
        CATransaction.commit()
        // if needed, hide emptyview
        if !self.model.areCommentsEmpty() {
            hideEmptyStateView()
        }
    }

    @objc
    func dataSource(didChangeRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SPReplyCell {
            cell.configure(with: model.dataSource.cellData(for: indexPath), lineLimit: messageLineLimit, isReadOnlyMode: isReadOnlyModeEnabled(), windowWidth: self.view.window?.frame.width)
        } else if let cell = tableView.cellForRow(at: indexPath) as? SPCommentCell {
            cell.setup(with: model.dataSource.cellData(for: indexPath),
                       shouldShowHeader: indexPath.section != 0,
                       minimumVisibleReplies: model.dataSource.minVisibleReplies,
                       lineLimit: messageLineLimit,
                       isReadOnlyMode: isReadOnlyModeEnabled(),
                       windowWidth: self.view.window?.frame.width)
        }
    }

    func dataSource(dataSource: SPMainConversationDataSource, didCollapseRowsAt indexPaths: [IndexPath]) {
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }

    func dataSource(dataSource: SPMainConversationDataSource, didRemoveSection section: Int) {
        removeSectionAt(index: section)
    }
}

extension SPBaseConversationViewController: SPCommentCellDelegate {
    @objc
    func showMoreReplies(for commentId: String?) {
        fatalError("Implement in subclass")
    }

    func changeRank(with change: SPRankChange, for commentId: String?, with replyingToID: String?) {
        guard let config = SPConfigsDataSource.appConfig,
              config.initialization?.policyAllowGuestsToLike == true ||
                SPUserSessionHolder.session.user?.registered == true
        else {
            self.startLoginFlow()
            return
        }
        // track event
        switch change.operation {
        case "like":
            SPAnalyticsHolder.default.log(event: .commentRankUpButtonClicked(messageId: commentId ?? "", relatedMessageId: replyingToID), source: .conversation)

        case "toggle-like":
            SPAnalyticsHolder.default.log(event: .commentRankUpButtonUndo(messageId: commentId ?? "", relatedMessageId: replyingToID), source: .conversation)

        case "dislike":
            SPAnalyticsHolder.default.log(event: .commentRankDownButtonClicked(messageId: commentId ?? "", relatedMessageId: replyingToID), source: .conversation)

        case "toggle-dislike":
            SPAnalyticsHolder.default.log(event: .commentRankDownButtonUndo(messageId: commentId ?? "", relatedMessageId: replyingToID), source: .conversation)

        default:
            break
        }

        model.dataSource.updateRank(with: change, inCellWith: commentId)
        let rankActionDataModel = RankActionDataModel(change: change,
                                                      commentId: commentId,
                                                      parrentId: replyingToID,
                                                      conversationId: model.dataSource.postId)
        model.changeRank(with: rankActionDataModel) { [weak self] success, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(
                    title: LocalizationManager.localizedString(key: "Oops..."),
                    message: error.localizedDescription
                )
                self.model.dataSource.updateRank(with: change.reversed, inCellWith: commentId)
            } else if success == false {
                self.showAlert(
                    title: LocalizationManager.localizedString(key: "Oops..."),
                    message: LocalizationManager.localizedString(key:
                        "It seems we are experiencing technical issues. Please try again")
                )
                self.model.dataSource.updateRank(with: change.reversed, inCellWith: commentId)
            }
        }
    }

    func hideReplies(for commentId: String?) {
        if let commentId = commentId {
            let relatedCommentId = model.dataSource.commentViewModel(commentId)?.rootCommentId
            SPAnalyticsHolder.default.log(
                event: .hideMoreRepliesClicked(
                    messageId: commentId,
                    relatedMessageId: relatedCommentId),
                source: .conversation)
        }
        model.dataSource.hideReplies(for: commentId)
    }

    func replyTapped(for commentId: String?) {
        guard let id = commentId, let delegate = delegate else { return }

        guard SpotIm.reactNativeShowLoginScreenOnRootVC,
              SPUserSessionHolder.session.user?.id == nil else {
            logCreationOpen(with: .reply, parentId: commentId)
            delegate.createReply(with: model, to: id)
            return
        }

        self.startLoginFlow()
    }

    func moreTapped(for commentId: String?, replyingToID: String?, sender: OWUISource) {
        guard let commentId = commentId else { return }

        SPAnalyticsHolder.default.log(
            event: .messageContextMenuClicked(messageId: commentId, relatedMessageId: replyingToID),
            source: .conversation
        )

        let actions = model.commentAvailableActions(commentId, sender: sender)
        if !actions.isEmpty {
            showActionSheet(actions: actions, sender: sender)
        } else {
            servicesProvider.logger().log(level: .verbose, "Showing the user a message because there are no available options to interact with a comment after pressing the 3 dots")
            let actions = [UIRxAlertAction(title: LocalizationManager.localizedString(key: "OK"), style: .default)]
            _ = UIAlertController.rx.show(onViewController: self, title: "",
                                      message: LocalizationManager.localizedString(key: "No available options"),
                                      actions: actions)
                .take(2) // Taking 2 cause the first one is the completion. No need to dispose cause the whole subscription will finish when the user select an option
                .subscribe(onNext: { [weak self] result in
                    switch result {
                    case .completion:
                        // Do nothing
                        break
                    case .selected(let action):
                        if action == actions.first {
                            self?.servicesProvider.logger().log(level: .verbose, "User pressed OK option")
                        }
                    }
                })
        }
    }

    func showMoreText(for commentId: String?) {
        guard let indexPath = model.dataSource.indexPathOfComment(with: commentId) else { return }
        model.dataSource.expandCommentText(for: indexPath)
        tableView.reloadData()
        handleCommentSizeChange()
    }

    func showLessText(for commentId: String?) {
        guard let indexPath = model.dataSource.indexPathOfComment(with: commentId) else { return }
        model.dataSource.collapseCommentText(for: indexPath)
        tableView.reloadData()
        handleCommentSizeChange()
    }

    func clickOnUrlInComment(url: URL) {
        webPageDelegate?.openWebPage(with: url.absoluteString)
    }

    private func startLoginFlow() {
        if SpotIm.reactNativeShowLoginScreenOnRootVC &&
            self.isInFullConversationVC() {
            self.navigationController?.popViewController(animated: false)
        }

        userAuthFlowDelegate?.presentAuth()
        self.didStartSignInFlow()
    }
}

extension SPBaseConversationViewController: MainConversationModelDelegate {

    func stopTypingTrack() {
        dismissTypingViewToTheSide()
    }

    func totalTypingCountDidUpdate(count: Int, newCommentsCount: Int) {
        handleTypingIndicationViewUpdate(typingCount: count, newCommentsCount: newCommentsCount, shouldShowBlitz: model.realtimeViewType == .blitz)
    }

    func realtimeViewTypeDidUpdate() {
        do {
            handleTypingIndicationViewUpdate(typingCount: try model.typingCount(), newCommentsCount: model.newMessagesCount(), shouldShowBlitz: model.realtimeViewType == .blitz)
        } catch {
            if let realtimeError = error as? RealTimeError {
                model.stopRealTimeFetching()
                SPDefaultFailureReporter.shared.report(error: .realTimeError(realtimeError))
            }
        }
    }

}

extension SPBaseConversationViewController: OWCommentCreationEntryViewDelegate {
    func labelContainerDidTap() {
        guard let delegate = delegate else { return }

        if SpotIm.reactNativeShowLoginScreenOnRootVC &&
            SPUserSessionHolder.session.user?.id == nil {
            self.startLoginFlow()
            return
        }
        logCreationOpen(with: .comment)
        delegate.createComment(with: model)
    }

    func userAvatarDidTap() {
        myUserAvatarDidTap()
    }

    private func isInFullConversationVC() -> Bool {
        return self is SPMainConversationViewController
    }
}

extension SPBaseConversationViewController: CommentsActionDelegate {

    func localCommentWillBeCreated() {
        guard tableView.numberOfSections > 0,
            tableView.numberOfRows(inSection: 0) > 0,
            tableView.indexPathsForVisibleRows?.count ?? 0 > 0 else { return }

        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .middle, animated: false)
    }

    func localCommentWasCreated() {
        servicesProvider.logger().log(level: .verbose, "FirstComment:")
        model.handlePendingComment()
    }

    func messageCreationBlocked(with messageText: String?) {
        DispatchQueue.main.async {
            self.presentMessageBlockedAlert(with: messageText)
        }
    }

    func prepareFlowForAction(_ type: ActionType, sender: OWUISource) {
        switch type {
        case .delete(let commentId, let replyingToID):
            showCommentDeletionFlow(commentId, replyingToID: replyingToID)

        case .report(let commentId, let replyingToID):
            showCommentReportFlow(commentId, replyingToID: replyingToID)

        case .edit(let commentId, _):
            showCommentEditingFlow(commentId)

        case .share(let commentId, let replyingToID):
            showCommentShareFlow(commentId, sender: sender, replyingToID: replyingToID)

        case .mute(let commentId, let replyingToID, let userId):
            showCommentMuteFlow(commentId, replyingToID: replyingToID, userId: userId)
        }
    }

    private func showCommentDeletionFlow(_ commentId: String, replyingToID: String?) {
        let yesAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Delete"),
            style: .destructive) { [weak self] _ in
                self?.showLoader()
                self?.model.deleteComment(with: commentId) { error in
                    self?.hideLoader()
                    SPAnalyticsHolder.default.log(event: .commentDeleteClicked(messageId: commentId, relatedMessageId: replyingToID), source: .conversation)
                    if let error = error {
                        self?.showAlert(
                            title: LocalizationManager.localizedString(key: "Oops..."),
                            message: error.localizedDescription
                        )
                    }
                    // after delete comment, show emptystate if needed
                    if let isEmpty = self?.model.areCommentsEmpty(), isEmpty {
                        self?.showEmptyStateView()
                    }
                }
        }

        let noAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"),
                                     style: .default)
        showAlert(
            title: LocalizationManager.localizedString(key: "Delete Comment"),
            message: LocalizationManager.localizedString(key: "Do you really want to delete this comment?"),
            actions: [noAction, yesAction])
    }

    private func showCommentReportFlow(_ commentId: String, replyingToID: String?) {
        let yesAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Report"),
            style: .destructive) { [weak self] _ in
                self?.showLoader()
                self?.model.reportComment(with: commentId) { error in
                    self?.hideLoader()
                    if let error = error {
                        self?.showAlert(
                            title: LocalizationManager.localizedString(key: "Oops..."),
                            message: error.localizedDescription
                        )
                    } else {
                        self?.showAlert(
                            title: LocalizationManager.localizedString(key: "Report Comment"),
                            message: LocalizationManager.localizedString(key: "Comment reported successfully")
                        )
                    }
                }
        }

        let noAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"),
                                     style: .default)
        showAlert(
            title: LocalizationManager.localizedString(key: "Report Comment"),
            message: LocalizationManager.localizedString(key: "Reporting this comment will send it for review and hide it from your view"),
            actions: [noAction, yesAction])
        SPAnalyticsHolder.default.log(event: .commentReportClicked(messageId: commentId, relatedMessageId: replyingToID), source: .conversation)
    }

    private func showCommentMuteFlow(_ commentId: String, replyingToID: String?, userId: String) {
        let muteAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Mute"),
            style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.showLoader()
                self.model.muteComment(with: userId) { error in
                    self.hideLoader()
                    if let error = error {
                        self.showAlert(
                            title: LocalizationManager.localizedString(key: "Oops..."),
                            message: error.localizedDescription
                        )
                    }
                }
                SPAnalyticsHolder.default.log(event: .commentMuteClicked(messageId: commentId, relatedMessageId: replyingToID, muteUserId: userId), source: .conversation)
        }

        let cancelAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Cancel"),
                                     style: .default)

        let message = "Muting this user will not allow you to see any action done by them. To reverse or manage your muted users, enter your profile settings"
        showAlert(
            title: LocalizationManager.localizedString(key: "Mute User"),
            message: LocalizationManager.localizedString(key: message),
            actions: [muteAction, cancelAction])
    }

    private func showCommentShareFlow(_ commentId: String, sender: OWUISource, replyingToID: String?) {
        showLoader()
        model.shareComment(with: commentId) { [weak self] url, error in
            guard let self = self else { return }

            self.hideLoader()
            if let error = error {
                self.showAlert(
                    title: LocalizationManager.localizedString(key: "Oops..."),
                    message: error.localizedDescription
                )
            } else if let url = url {
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = sender
                self.present(activityViewController, animated: true, completion: nil)
            }
            SPAnalyticsHolder.default.log(event: .commentShareClicked(messageId: commentId, relatedMessageId: replyingToID), source: .conversation)
        }
    }

    private func showCommentEditingFlow(_ commentId: String) {
        self.delegate?.editComment(with: self.model, to: commentId)
    }

    private func presentMessageBlockedAlert(with messageText: String?) {
        let copyAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Copy Comment to Clipboard"),
            style: .default) { _ in
                UIPasteboard.general.string = messageText
        }
        let gotItAction = UIAlertAction(title: LocalizationManager.localizedString(key: "Got it"),
                                        style: .default)
        showAlert(
            title: LocalizationManager.localizedString(key: "This comment violated our policy."),
            message: LocalizationManager.localizedString(key: "It seems like your comment has violated our policy. We recommend you try again with different phrasing."),
            actions: [copyAction, gotItAction]
        )
    }
}

extension SPBaseConversationViewController: SPCommunityGuidelinesViewDelegate {
    func clickOnUrl(url: URL) {
        webPageDelegate?.openWebPage(with: SPWebSDKProvider.urlWithDarkModeParam(url: url).absoluteString)
    }
    func customizeTextView(textView: UITextView, source: SPViewSourceType) {
        customUIDelegate?.customizeView(.communityGuidelines(textView: textView), source: source)
    }
}

extension SPBaseConversationViewController: SPLoginPromptViewDelegate {
    func userTapOnLoginPrompt() {
        if let userAuthFlowDelegate = self.userAuthFlowDelegate {
            userAuthFlowDelegate.presentAuth()
        }
    }
}

extension SPBaseConversationViewController: OpenUserProfileDelegate {
    func openProfileWebScreen(userId: String) {
        guard let mobileSdkConfig = SPConfigsDataSource.appConfig?.mobileSdk,
              mobileSdkConfig.profileEnabled == true,
              let spotId = SPClientSettings.main.spotKey else { return }
        let params = SPWebSDKProvider.Params(
            module: .profile,
            spotId: spotId,
            postId: model.dataSource.postId,
            userId: userId
        )

        let isMyProfile = SPPublicSessionInterface.isMe(userId: userId)

        if isMyProfile {
            // add singleUseTicket to params when navigating to profile screen
            _ = SpotIm.profileProvider.getSingleUseToken()
                .take(1)
                .observe(on: MainScheduler.asyncInstance)
                .subscribe(onNext: { [weak self] singleUseToken in
                    guard let self = self else { return }
                    params.singleUseTicket = singleUseToken
                    SPWebSDKProvider.openWebModule(delegate: self.webPageDelegate, params: params)
                }, onError: { [weak self] error in
                    self?.servicesProvider.logger().log(level: .verbose, "Failed to get single use token: \(error)")
                })
        } else {
            SPWebSDKProvider.openWebModule(delegate: webPageDelegate, params: params)
        }
    }

    func getCurrentNavigationController() -> UINavigationController? {
        return navigationController
    }
}
