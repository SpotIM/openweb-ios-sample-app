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

    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()
    private let commentLabelView: CommentLabelView = .init()
    private let replyActionsView: CommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    private let headerView: BaseView = .init()
    private let separatorView: BaseView = .init()
    private let commentMediaView: CommentMediaView = .init()
    
    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed
    
    private var replyActionsViewHeightConstraint: NSLayoutConstraint?
    private var moreRepliesViewHeightConstraint: NSLayoutConstraint?
    private var headerViewHeightConstraint: NSLayoutConstraint?
    private var userNameViewTopConstraint: NSLayoutConstraint?
    private var separatorHeightConstraint: NSLayoutConstraint?
    private var commentLabelHeightConstraint: NSLayoutConstraint?
    private var commentMediaViewTopConstraint: NSLayoutConstraint?
    private var commentMediaHeightConstraint: NSLayoutConstraint?
    private var commentMediaWidthConstraint: NSLayoutConstraint?

    private var userViewHeightConstraint: NSLayoutConstraint?
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
        messageView.updateColorsAccordingToStyle()
        userNameView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        avatarImageView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
        commentLabelView.updateColorsAccordingToStyle()
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
    }

    // MARK: - Private Methods - View setup

    private func setupUI() {
        contentView.addSubviews(headerView,
                                avatarImageView,
                                userNameView,
                                commentLabelView,
                                messageView,
                                commentMediaView,
                                replyActionsView,
                                moreRepliesView)
        configureHeaderView()
        configureAvatarView()
        configureUserNameView()
        configureCommentLabelView()
        configureMessageView()
        configureCommentMediaView()
        configureReplyActionsView()
        configureMoreRepliesView()
    }

    private func configureHeaderView() {
        separatorView.backgroundColor = .spSeparator2
        headerView.addSubview(separatorView)
        separatorView.layout {
            $0.centerX.equal(to: headerView.centerXAnchor)
            $0.centerY.equal(to: headerView.centerYAnchor)
            $0.leading.equal(to: headerView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: headerView.trailingAnchor, offsetBy: -Theme.leadingOffset)
            separatorHeightConstraint = $0.height.equal(to: 1.0)
        }
        
        headerView.backgroundColor = .spBackground0
        headerView.layout {
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.top.equal(to: contentView.topAnchor)
            headerViewHeightConstraint = $0.height.equal(to: 0.0)
        }
    }
    
    private func configureAvatarView() {
        avatarImageView.delegate = self
        avatarImageView.layout {
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: userNameView.leadingAnchor, offsetBy: -Theme.avatarImageViewTrailingOffset)
            $0.centerY.equal(to: userNameView.centerYAnchor)
            $0.height.equal(to: Theme.avatarSideSize)
            $0.width.equal(to: Theme.avatarSideSize)
        }
    }
    
    private func configureUserNameView() {
        userNameView.delegate = self
        userNameView.layout {
            userNameViewTopConstraint = $0.top.equal(to: headerView.bottomAnchor, offsetBy: Theme.topOffset)
            $0.trailing.equal(to: contentView.trailingAnchor)
            userViewHeightConstraint = $0.height.equal(to: Theme.userViewCollapsedHeight)
        }
    }
    
    private func configureCommentLabelView() {
        commentLabelView.layout {
            $0.top.equal(to: userNameView.bottomAnchor, offsetBy: 10)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            commentLabelHeightConstraint = $0.height.equal(to: Theme.commentLabelHeight)
        }
    }
    
    private func configureMessageView() {
        messageView.layout {
            $0.top.equal(to: commentLabelView.bottomAnchor, offsetBy: Theme.messageContainerTopOffset)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func configureCommentMediaView() {
        commentMediaView.layout {
            commentMediaViewTopConstraint = $0.top.equal(to: messageView.bottomAnchor, offsetBy: SPCommonConstants.emptyCommentMediaTopPadding)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.lessThanOrEqual(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            commentMediaHeightConstraint = $0.height.equal(to: 0)
            commentMediaWidthConstraint = $0.width.equal(to: 0)
        }
    }
    
    private func configureReplyActionsView() {
        replyActionsView.delegate = self
        
        replyActionsView.layout {
            $0.top.equal(to: commentMediaView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            replyActionsViewHeightConstraint = $0.height.equal(to: Theme.replyActionsViewHeight)
        }
    }
    
    private func configureMoreRepliesView() {
        moreRepliesView.delegate = self
        moreRepliesView.layout {
            $0.top.equal(to: replyActionsView.bottomAnchor, offsetBy: Theme.moreRepliesTopOffset)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.lessThanOrEqual(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            moreRepliesViewHeightConstraint = $0.height.equal(to: Theme.moreRepliesViewHeight)
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
            isLeader: dataModel.showsStar,
            contentType: .reply,
            isDeleted: dataModel.isDeletedOrReported())
        userNameView.setMoreButton(hidden: dataModel.isDeletedOrReported())
        userNameView.setSubtitle(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? dataModel.timestamp
                : "\(dataModel.replyingToDisplayName!) · ".appending(dataModel.timestamp ?? "")
        )
        let userViewHeight = dataModel.badgeTitle == nil ? Theme.userViewCollapsedHeight : Theme.userViewExpandedHeight
        userViewHeightConstraint?.constant = userViewHeight
        userNameViewTopConstraint?.constant = dataModel.isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset

    }
    
    private func updateCommentLabelView(with dataModel: CommentViewModel) {
        if let commentLabel = dataModel.commentLabel,
           dataModel.isDeletedOrReported() == false {
            commentLabelView.setLabel(commentLabelIconUrl: commentLabel.iconUrl, labelColor: commentLabel.color, labelText: commentLabel.text, labelId: commentLabel.id, state: .readOnly)
            commentLabelView.isHidden = false
            commentLabelHeightConstraint?.constant = Theme.commentLabelHeight
        } else {
            commentLabelHeightConstraint?.constant = 0
            commentLabelView.isHidden = true
        }
    }
    
    private func updateActionView(with dataModel: CommentViewModel, isReadOnlyMode: Bool) {
        replyActionsView.setReadOnlyMode(enabled: isReadOnlyMode)
        replyActionsView.setBrandColor(.brandColor)
        replyActionsView.setReplyButton(repliesCount: dataModel.repliesCount)
        replyActionsView.setRankUp(dataModel.rankUp)
        replyActionsView.setRankDown(dataModel.rankDown)
        replyActionsView.setRanked(with: dataModel.rankedByUser)
        replyActionsViewHeightConstraint?.constant = dataModel.isDeletedOrReported() ? 0.0 : Theme.replyActionsViewHeight
    }
    
    private func updateHeaderView(with dataModel: CommentViewModel, shouldShowHeader: Bool) {
        headerViewHeightConstraint?.constant = shouldShowHeader ? 7.0 : 0.0
        separatorHeightConstraint?.constant = shouldShowHeader ? 1.0 : 0.0

        separatorView.backgroundColor = .spSeparator2
    }
    
    private func updateAvatarView(with dataModel: CommentViewModel) {
        imageRequest?.cancel()
        avatarImageView.updateAvatar(image: nil)
        avatarImageView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        if !dataModel.isDeletedOrReported() {
            imageRequest = UIImage.load(with: dataModel.userAvatar) { [weak self] image, _ in
                self?.avatarImageView.updateAvatar(image: image)
            }
            avatarImageView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        } else {
            avatarImageView.updateOnlineStatus(.offline)
        }
    }
    
    private func updateMoreRepliesView(with dataModel: CommentViewModel, minimumVisibleReplies: Int) {
        moreRepliesViewHeightConstraint?.constant = dataModel.isCollapsed ? 0.0
        : (dataModel.repliesButtonState == .hidden ? 0.0 : Theme.moreRepliesViewHeight)
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
            commentMediaViewTopConstraint?.constant = SPCommonConstants.emptyCommentMediaTopPadding
            commentMediaWidthConstraint?.constant = 0
            commentMediaHeightConstraint?.constant = 0
            commentMediaView.clearExistingMedia()
            return
        }
        let mediaSize = dataModel.getMediaSize()
        commentMediaView.configureMedia(imageUrl: dataModel.commentImage?.imageUrl, gifUrl: dataModel.commentGifUrl)
        commentMediaViewTopConstraint?.constant = SPCommonConstants.commentMediaTopPadding
        commentMediaWidthConstraint?.constant = mediaSize.width
        commentMediaHeightConstraint?.constant = mediaSize.height
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
    
    func rankUp(_ rankChange: SPRankChange, updateRankLocal: () -> Void) {
        delegate?.changeRank(with: rankChange, for: commentId, with: replyingToId, updateRankLocal: updateRankLocal)
    }
    
    func rankDown(_ rankChange: SPRankChange, updateRankLocal: () -> Void) {
        delegate?.changeRank(with: rankChange, for: commentId, with: replyingToId, updateRankLocal: updateRankLocal)
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

extension SPCommentCell: AvatarViewDelegate {
    
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
    func changeRank(with change: SPRankChange, for commentId: String?, with replyingToID: String?, updateRankLocal: () -> Void)
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
    static let replyActionsViewHeight: CGFloat = 49.0
    static let moreRepliesViewHeight: CGFloat = 31.0
    static let userViewCollapsedHeight: CGFloat = 44.0
    static let userViewExpandedHeight: CGFloat = 69.0
    static let avatarSideSize: CGFloat = 39.0
    static let avatarImageViewTrailingOffset: CGFloat = 11.0
    static let moreRepliesTopOffset: CGFloat = 12.0
    static let commentLabelHeight: CGFloat = 28.0
}
