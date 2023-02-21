//
//  SPCommentCell.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol MessageItemContainable: AnyObject {
    var messageView: MessageContainerView { get }
}

extension MessageItemContainable {

    func containsChatItem(at point: CGPoint) -> Bool {
        return messageView.frame.contains(point)
    }
}

internal final class SPCommentCell: SPBaseTableViewCell, MessageItemContainable {
    fileprivate struct Metrics {
        static let identifier = "comment_cell_id"
        static let contentViewIdentifier = "comment_cell_content_view_id"
        static let messageIdentifier = "comment_cell_message_id"
        static let userCommentIdentifier = "comment_cell_user_comment_id"
        static let statusIndicationIdentifier = "comment_cell_status_indication_id"
        static let commentLabelIdentifier = "comment_cell_comment_label_id"
        static let replyActionsIdentifier = "comment_cell_reply_actions_id"
        static let moreRepliesIdentifier = "comment_cell_more_replies_id"
        static let headerIdentifier = "comment_cell_header_id"
    }

    weak var delegate: SPCommentCellDelegate? {
        didSet {
            userView.setDelegate(delegate)
        }
    }

    let messageView: MessageContainerView = .init()

    private let userView: OWCommentUserView = .init()
    private let statusIndicationView = OWCommentStatusIndicationView()
    private let commentLabelView: CommentLabelView = .init()
    private let replyActionsView: OWCommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    private let headerView: OWBaseView = .init()
    private let separatorView: OWBaseView = .init()
    private let commentMediaView: CommentMediaView = .init()
    private let opacityView: OWBaseView = .init()

    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed

    private var userViewTopConstraint: OWConstraint?
    private var commentMediaViewTopConstraint: OWConstraint?
    private var statusIndicatorViewHeighConstraint: OWConstraint?
    private var statusIndicatorViewTopConstraint: OWConstraint?

    private var imageRequest: OWNetworkDataRequest?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        headerView.backgroundColor = .spBackground0
        contentView.backgroundColor = .spBackground0
        opacityView.backgroundColor = .spBackground0
        messageView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
        commentLabelView.updateColorsAccordingToStyle()
        userView.updateColorsAccordingToStyle()
        statusIndicationView.updateColorsAccordingToStyle()
    }

    // MARK: - Internal methods

    internal func setup(
        with data: CommentViewModel,
        shouldShowHeader: Bool,
        minimumVisibleReplies: Int,
        lineLimit: Int,
        isReadOnlyMode: Bool,
        windowWidth: CGFloat?
    ) {
        commentId = data.commentId
        replyingToId = data.replyingToCommentId
        repliesButtonState = data.repliesButtonState
        messageView.delegate = self

        updateActionView(with: data, isReadOnlyMode: isReadOnlyMode)
        updateUserView(with: data)
        updateHeaderView(with: data, shouldShowHeader: shouldShowHeader)
        updateCommentMediaView(with: data)
        updateMoreRepliesView(with: data, minimumVisibleReplies: minimumVisibleReplies)
        updateMessageView(with: data, clipToLine: lineLimit, windowWidth: windowWidth)
        updateCommentLabelView(with: data)
        userViewTopConstraint?.update(offset: data.isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset)
        setStatusIndicatorVisibillity(isVisible: data.showStatusIndicator)
        statusIndicationView.configure(with: data.statusIndicationVM)
    }

    // MARK: - Private Methods - View setup

    private func setupUI() {
        contentView.addSubviews(headerView,
                                userView,
                                statusIndicationView,
                                commentLabelView,
                                messageView,
                                commentMediaView,
                                replyActionsView,
                                moreRepliesView,
                                opacityView)
        configureHeaderView()
        configureUserView()
        configureOpacityView()
        configureStatusIndicationView()
        configureCommentLabelView()
        configureMessageView()
        configureCommentMediaView()
        configureReplyActionsView()
        configureMoreRepliesView()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        headerView.accessibilityIdentifier = Metrics.headerIdentifier
        userView.accessibilityIdentifier = Metrics.userCommentIdentifier
        commentLabelView.accessibilityIdentifier = Metrics.commentLabelIdentifier
        messageView.accessibilityIdentifier = Metrics.messageIdentifier
        replyActionsView.accessibilityIdentifier = Metrics.replyActionsIdentifier
        moreRepliesView.accessibilityIdentifier = Metrics.moreRepliesIdentifier
        statusIndicationView.accessibilityIdentifier = Metrics.statusIndicationIdentifier
    }

    private func configureStatusIndicationView() {
        statusIndicationView.OWSnp.makeConstraints { make in
            statusIndicatorViewTopConstraint = make.top.equalTo(headerView).offset(Theme.statusIndicatorTopOffset).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.leadingOffset)
            statusIndicatorViewHeighConstraint = make.height.equalTo(0).constraint
        }
    }

    private func configureOpacityView() {
        opacityView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(userView.OWSnp.top)
        }
        opacityView.layer.opacity = 0.4
        opacityView.isUserInteractionEnabled = false
    }

    private func configureHeaderView() {
        separatorView.backgroundColor = .spSeparator2
        headerView.addSubview(separatorView)
        separatorView.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.leadingOffset)
            make.height.equalTo(1.0)
        }

        headerView.backgroundColor = .spBackground0
        headerView.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(0.0)
        }
    }

    private func configureUserView() {
        userView.OWSnp.makeConstraints { make in
            userViewTopConstraint = make.top.equalTo(statusIndicationView.OWSnp.bottom).offset(Theme.topOffset).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview()
            make.height.equalTo(Theme.userViewCollapsedHeight)
        }
    }

    private func configureCommentLabelView() {
        commentLabelView.OWSnp.makeConstraints { make in
            make.top.equalTo(userView.OWSnp.bottom).offset(10)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.height.equalTo(Theme.commentLabelHeight)
        }
    }

    private func configureMessageView() {
        messageView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelView.OWSnp.bottom).offset(Theme.messageContainerTopOffset)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
        }
    }

    private func configureCommentMediaView() {
        commentMediaView.OWSnp.makeConstraints { make in
            commentMediaViewTopConstraint = make.top.equalTo(messageView.OWSnp.bottom).offset(SPCommonConstants.emptyCommentMediaTopPadding).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.trailingOffset)
            make.height.equalTo(0)
            make.width.equalTo(0)
        }
    }

    private func configureReplyActionsView() {
        replyActionsView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentMediaView.OWSnp.bottom)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
            make.height.equalTo(Theme.replyActionsViewHeight)
        }
    }

    private func configureMoreRepliesView() {
        moreRepliesView.delegate = self
        moreRepliesView.OWSnp.makeConstraints { make in
            make.top.equalTo(replyActionsView.OWSnp.bottom).offset(Theme.moreRepliesTopOffset)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.trailingOffset)
            make.height.equalTo(Theme.moreRepliesViewHeight)
        }
    }

    private func updateRepliesButtonTitle(with repliesCount: Int?, minimumVisibleRepliesCount: Int) {
        if let repliesCount = repliesCount, repliesCount == minimumVisibleRepliesCount + 1 {
            moreRepliesView.collapsedTitle = LocalizationManager.localizedString(key: "View Previous Reply")
            moreRepliesView.expandedTitle = LocalizationManager.localizedString(key: "Hide Reply")
        } else {
            moreRepliesView.collapsedTitle = LocalizationManager.localizedString(key: "View Previous Replies")
            moreRepliesView.expandedTitle = LocalizationManager.localizedString(key: "Hide Replies")
        }
    }

    private func setStatusIndicatorVisibillity(isVisible: Bool) {
        statusIndicationView.isHidden = !isVisible
        statusIndicatorViewHeighConstraint?.isActive = !isVisible
        statusIndicatorViewTopConstraint?.update(offset: isVisible ? Theme.statusIndicatorTopOffset :0)
        opacityView.isHidden = !isVisible

    }

    private func updateCommentLabelView(with dataModel: CommentViewModel) {
        let labelHeight: CGFloat
        if let commentLabels = dataModel.commentLabels,
           dataModel.isHiddenComment() == false,
           commentLabels.count > 0 {
            let selectedCommentLabel = commentLabels[0]
            commentLabelView.setLabel(
                commentLabelIconUrl: selectedCommentLabel.iconUrl,
                labelColor: selectedCommentLabel.color,
                labelText: selectedCommentLabel.text,
                labelId: selectedCommentLabel.id,
                state: .readOnly)
            commentLabelView.isHidden = false
            labelHeight = Theme.commentLabelHeight
        } else {
            labelHeight = 0
            commentLabelView.isHidden = true
        }

        commentLabelView.OWSnp.updateConstraints { make in
            make.height.equalTo(labelHeight)
        }
    }

    private func updateActionView(with dataModel: CommentViewModel, isReadOnlyMode: Bool) {
        replyActionsView.configure(with: dataModel.commentActionsVM, delegate: self)
        dataModel.updateCommentActionsVM()
        replyActionsView.setReadOnlyMode(enabled: isReadOnlyMode)
        replyActionsView.setReplyButton(repliesCount: dataModel.repliesCount)
        replyActionsView.setIsDisabled(isDisabled: dataModel.showStatusIndicator)
        replyActionsView.OWSnp.updateConstraints { make in
            make.height.equalTo(dataModel.isHiddenComment() ? 0.0 : Theme.replyActionsViewHeight)
        }
    }

    private func updateUserView(with dataModel: CommentViewModel) {
        dataModel.commentUserVM.inputs.configure(with: dataModel)
        let avatarVM = dataModel.commentUserVM.outputs.avatarVM
        avatarVM.inputs.changeAvatarVisibility(isVisible: !dataModel.isHiddenComment())
        userView.configure(with: dataModel)
    }

    private func updateHeaderView(with dataModel: CommentViewModel, shouldShowHeader: Bool) {
        headerView.OWSnp.updateConstraints { make in
            make.height.equalTo(shouldShowHeader ? 7.0 : 0.0)
        }
        separatorView.OWSnp.updateConstraints { make in
            make.height.equalTo(shouldShowHeader ? 1.0 : 0.0)
        }

        separatorView.backgroundColor = .spSeparator2
    }

    private func updateMoreRepliesView(with dataModel: CommentViewModel, minimumVisibleReplies: Int) {
        let height = dataModel.isCollapsed ? 0.0 : (dataModel.repliesButtonState == .hidden ? 0.0 : Theme.moreRepliesViewHeight)
        moreRepliesView.OWSnp.updateConstraints { make in
            make.height.equalTo(height)
        }
        updateRepliesButtonTitle(
            with: dataModel.repliesRawCount,
            minimumVisibleRepliesCount: minimumVisibleReplies
        )
        moreRepliesView.updateView(with: dataModel.repliesButtonState)
    }

    private func updateMessageView(with dataModel: CommentViewModel, clipToLine: Int, windowWidth: CGFloat?) {
        if messageView.frame.width < 1 {
            setNeedsLayout()
            layoutIfNeeded()
        }
        if dataModel.isHiddenComment() {
            messageView.setMessage(
                "",
                attributes: attributes(isDeleted: true),
                clippedTextSettings: SPClippedTextSettings(
                    collapsed: dataModel.commentTextCollapsed,
                    edited: dataModel.isEdited
                )
            )
        } else {
            messageView.setMessage(dataModel.commentText ?? "",
                                   attributes: attributes(isDeleted: false),
                                   clipToLine: clipToLine,
                                   width: dataModel.textWidth(),
                                   clippedTextSettings: SPClippedTextSettings(
                                    collapsed: dataModel.commentTextCollapsed,
                                    edited: dataModel.isEdited
                                   )
                               )
        }
    }

    private func updateCommentMediaView(with dataModel: CommentViewModel) {
        guard !dataModel.isHiddenComment() && (dataModel.commentGifUrl != nil || dataModel.commentImage != nil) else {
            commentMediaViewTopConstraint?.update(offset: SPCommonConstants.emptyCommentMediaTopPadding)
            commentMediaView.OWSnp.updateConstraints { make in
                make.height.equalTo(0)
                make.width.equalTo(0)
            }
            commentMediaView.clearExistingMedia()
            return
        }
        let mediaSize = dataModel.getMediaSize()
        commentMediaView.configureMedia(imageUrl: dataModel.commentImage?.imageUrl, gifUrl: dataModel.commentGifUrl)
        commentMediaViewTopConstraint?.update(offset: SPCommonConstants.commentMediaTopPadding)
        commentMediaView.OWSnp.updateConstraints { make in
            make.height.equalTo(mediaSize.height)
            make.width.equalTo(mediaSize.width)
        }
    }

    private func attributes(isDeleted: Bool) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5
        paragraphStyle.updateAlignment()

        var attributes: [NSAttributedString.Key: Any]
        if isDeleted {
            attributes = [
                .foregroundColor: UIColor.spForeground3,
                .font: UIFont.preferred(style: .italic, of: Theme.deletedFontSize),
                .paragraphStyle: paragraphStyle
            ]
        } else {
            attributes = [
                .foregroundColor: UIColor.spForeground1,
                .font: UIFont.preferred(style: .regular, of: Theme.fontSize),
                .paragraphStyle: paragraphStyle
            ]
        }

        return attributes
    }
}

// MARK: - Extensions

extension SPCommentCell: CommentActionsDelegate {

    func reply() {
        delegate?.replyTapped(for: commentId)
    }

    func rankUp(_ rankChange: SPRankChange) {
        delegate?.changeRank(with: rankChange, for: commentId, with: replyingToId)
    }

    func rankDown(_ rankChange: SPRankChange) {
        delegate?.changeRank(with: rankChange, for: commentId, with: replyingToId)
    }

}

extension SPCommentCell: ShowMoreRepliesViewDelegate {

    func showHideReplies() {
        if repliesButtonState == .collapsed {
            delegate?.showMoreReplies(for: commentId)
        } else if repliesButtonState == .expanded {
            delegate?.hideReplies(for: commentId)
        }
    }
}

extension SPCommentCell: MessageContainerViewDelegate {

    func urlTappedInMessageContainer(view: MessageContainerView, url: URL) {
        delegate?.clickOnUrlInComment(url: url)
    }

    func readMoreTappedInMessageContainer(view: MessageContainerView) {
        delegate?.showMoreText(for: commentId)
        SPAnalyticsHolder.default.log(event: .commentReadMoreClicked(messageId: commentId ?? "", relatedMessageId: replyingToId), source: .conversation)
    }

    func readLessTappedInMessageContainer(view: MessageContainerView) {
        delegate?.showLessText(for: commentId)
        SPAnalyticsHolder.default.log(event: .commentReadLessClicked(messageId: commentId ?? "", relatedMessageId: replyingToId), source: .conversation)
    }

}

// Cell life cycle
extension SPCommentCell {
    override func prepareForReuse() {
        replyActionsView.prepareForReuse()
        super.prepareForReuse()
    }
}

// MARK: - RepliesButtonState

enum RepliesButtonState {
    case collapsed
    case expanded
    case loading
    case hidden
}

// MARK: - Delegate

protocol SPCommentCellDelegate: AnyObject {
    func showMoreReplies(for commentId: String?)
    func hideReplies(for commentId: String?)
    func changeRank(with change: SPRankChange, for commentId: String?, with replyingToID: String?)
    func replyTapped(for commentId: String?)
    func moreTapped(for commentId: String?, replyingToID: String?, sender: OWUISource)
    func showMoreText(for commentId: String?)
    func showLessText(for commentId: String?)
    func clickOnUrlInComment(url: URL)
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let deletedFontSize: CGFloat = 17.0
    static let topOffset: CGFloat = 14.0
    static let topCollapsedOffset: CGFloat = 38.0
    static let bottomOffset: CGFloat = 15.0
    static let leadingOffset: CGFloat = 16.0
    static let trailingOffset: CGFloat = 16.0
    static let messageContainerTopOffset: CGFloat = 5.0
    static let replyActionsViewHeight: CGFloat = 32
    static let moreRepliesViewHeight: CGFloat = 31.0
    static let userViewCollapsedHeight: CGFloat = 44.0
    static let moreRepliesTopOffset: CGFloat = 12.0
    static let commentLabelHeight: CGFloat = 28.0
    static let statusIndicatorTopOffset: CGFloat = 16
}
