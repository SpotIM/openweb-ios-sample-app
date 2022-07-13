//
//  SPCommentCell.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Alamofire

protocol MessageItemContainable: AnyObject {
    var messageView: MessageContainerView { get }
}

extension MessageItemContainable {
    
    func containsChatItem(at point: CGPoint) -> Bool {
        return messageView.frame.contains(point)
    }
}

internal final class SPCommentCell: SPBaseTableViewCell, MessageItemContainable {
    
    weak var delegate: SPCommentCellDelegate?

    let messageView: MessageContainerView = .init()

    private let statusIndicationView = OWCommentStatusIndicationView()
    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()
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
    
    private var userNameViewTopConstraint: OWConstraint?
    private var commentMediaViewTopConstraint: OWConstraint?
    private var statusIndicatorViewHeighConstraint: OWConstraint?
    private var statusIndicatorViewTopConstraint: OWConstraint?
    
    private var imageRequest: DataRequest?

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
        userNameView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
        commentLabelView.updateColorsAccordingToStyle()
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
        
        updateUserView(with: data)
        updateActionView(with: data, isReadOnlyMode: isReadOnlyMode)
        updateAvatarView(with: data)
        updateHeaderView(with: data, shouldShowHeader: shouldShowHeader)
        updateCommentMediaView(with: data)
        updateMoreRepliesView(with: data, minimumVisibleReplies: minimumVisibleReplies)
        updateMessageView(with: data, clipToLine: lineLimit, windowWidth: windowWidth)
        updateCommentLabelView(with: data)
        setStatusIndicatorVisibillity(isVisible: data.showStatusIndicator)
        
        statusIndicationView.configure(with: data.statusIndicationVM)
    }

    // MARK: - Private Methods - View setup

    private func setupUI() {
        contentView.addSubviews(headerView,
                                statusIndicationView,
                                avatarImageView,
                                userNameView,
                                commentLabelView,
                                messageView,
                                commentMediaView,
                                replyActionsView,
                                moreRepliesView,
                                opacityView)
        configureHeaderView()
        configureOpacityView()
        configureStatusIndicationView()
        configureAvatarView()
        configureUserNameView()
        configureCommentLabelView()
        configureMessageView()
        configureCommentMediaView()
        configureReplyActionsView()
        configureMoreRepliesView()
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
            make.top.equalTo(userNameView.OWSnp.top)
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
    
    private func configureAvatarView() {
        avatarImageView.delegate = self
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalTo(userNameView.OWSnp.leading).offset(-Theme.avatarImageViewTrailingOffset)
            make.top.equalTo(userNameView)
            make.size.equalTo(Theme.avatarSideSize)
        }
    }
    
    private func configureUserNameView() {
        userNameView.delegate = self
        userNameView.OWSnp.makeConstraints { make in
            userNameViewTopConstraint = make.top.equalTo(statusIndicationView.OWSnp.bottom).offset(Theme.topOffset).constraint
            make.trailing.equalToSuperview()
            make.height.equalTo(Theme.userViewCollapsedHeight)
        }
    }
    
    private func configureCommentLabelView() {
        commentLabelView.OWSnp.makeConstraints { make in
            make.top.equalTo(userNameView.OWSnp.bottom).offset(10)
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
    
    private func updateUserView(with dataModel: CommentViewModel) {
        userNameView.setDeletedOrReported(isDeleted: dataModel.isDeleted, isReported: dataModel.isReported)
        
        userNameView.setUserName(
            dataModel.displayName,
            badgeTitle: dataModel.badgeTitle,
            contentType: .reply,
            isDeleted: dataModel.isDeletedOrReported(),
            isOneLine: dataModel.isUsernameOneRow())
        userNameView.setMoreButton(hidden: dataModel.isDeletedOrReported())
        userNameView.setSubtitle(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? dataModel.timestamp
                : "\(dataModel.replyingToDisplayName!) · ".appending(dataModel.timestamp ?? "")
        )
        let userViewHeight = dataModel.usernameViewHeight()
        userNameView.OWSnp.updateConstraints { make in
            make.height.equalTo(userViewHeight)
        }
        userNameViewTopConstraint?.update(offset: dataModel.isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset)

        userNameView.configureSubscriberBadgeVM(viewModel: dataModel.subscriberBadgeVM)
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
           dataModel.isDeletedOrReported() == false,
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
            make.height.equalTo(dataModel.isDeletedOrReported() ? 0.0 : Theme.replyActionsViewHeight)
        }
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
    
    private func updateAvatarView(with dataModel: CommentViewModel) {
        avatarImageView.configure(with: dataModel.avatarViewVM)
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
        if dataModel.isDeletedOrReported() {
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
        guard !dataModel.isDeletedOrReported() && (dataModel.commentGifUrl != nil || dataModel.commentImage != nil) else {
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
                .font: UIFont.openSans(style: .regularItalic, of: Theme.deletedFontSize),
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

extension SPCommentCell: UserNameViewDelegate {
    
    func moreButtonDidTapped(sender: UIButton) {
        delegate?.moreTapped(for: commentId, replyingToID: replyingToId, sender: sender)
    }
    
    func userNameDidTapped() {
        delegate?.respondToAuthorTap(for: commentId, isAvatarClicked: false)
    }
}

extension SPCommentCell: OWAvatarViewDelegate {
    
    func avatarDidTapped() {
        delegate?.respondToAuthorTap(for: commentId, isAvatarClicked: true)
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
    func moreTapped(for commentId: String?, replyingToID: String?, sender: UIButton)
    func respondToAuthorTap(for commentId: String?, isAvatarClicked: Bool)
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
    static let userViewExpandedHeight: CGFloat = 69.0
    static let avatarSideSize: CGFloat = 39.0
    static let avatarImageViewTrailingOffset: CGFloat = 11.0
    static let moreRepliesTopOffset: CGFloat = 12.0
    static let commentLabelHeight: CGFloat = 28.0
    static let statusIndicatorTopOffset: CGFloat = 16
}
