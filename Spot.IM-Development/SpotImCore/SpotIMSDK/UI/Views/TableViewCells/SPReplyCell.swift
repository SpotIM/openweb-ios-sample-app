//
//  SPReplyCell.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/6/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Alamofire

final class SPReplyCell: SPBaseTableViewCell, MessageItemContainable {

    weak var delegate: SPCommentCellDelegate?
    
    let messageView: MessageContainerView = .init()

    private let avatarView: SPAvatarView = .init()
    private let userNameView: UserNameView = .init()
    private let commentLabelView: CommentLabelView = .init()
    private let replyActionsView: CommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    private let commentMediaView: CommentMediaView = .init()
    
    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed
    
    private var replyActionsViewHeightConstraint: NSLayoutConstraint?
    private var moreRepliesViewHeightConstraint: NSLayoutConstraint?
    private var userViewHeightConstraint: NSLayoutConstraint?
    private var textViewLeadingConstraint: NSLayoutConstraint?
    private var commentLabelHeightConstraint: NSLayoutConstraint?
    private var commentMediaViewTopConstraint: NSLayoutConstraint?
    private var commentMediaViewHeightConstraint: NSLayoutConstraint?
    private var commentMediaViewWidthConstraint: NSLayoutConstraint?
    
    private var imageRequest: DataRequest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func configure(with data: CommentViewModel, lineLimit: Int, isReadOnlyMode: Bool, windowWidth: CGFloat?) {
        commentId = data.commentId
        replyingToId = data.replyingToCommentId
        repliesButtonState = data.repliesButtonState
        updateUserView(with: data)
        updateActionView(with: data, isReadOnlyMode: isReadOnlyMode)
        updateAvatarView(with: data)
        updateCommentLabelView(with: data)
        messageView.delegate = self
        
        textViewLeadingConstraint?.constant = data.depthOffset()
        if data.isDeletedOrReported() {
            messageView.setMessage("",
                                   attributes: attributes(isDeleted: true),
                                   clippedTextSettings: SPClippedTextSettings(
                                    collapsed: data.commentTextCollapsed,
                                    edited: data.isEdited
                                   )
                                  )
            replyActionsViewHeightConstraint?.constant = 0.0
            moreRepliesViewHeightConstraint?.constant = 0.0
        } else {
            messageView.setMessage(
                data.commentText ?? "",
                attributes: attributes(isDeleted: false),
                clipToLine: lineLimit,
                width: data.textWidth(),
                clippedTextSettings: SPClippedTextSettings(
                    collapsed: data.commentTextCollapsed,
                    edited: data.isEdited
                )
            )
            replyActionsViewHeightConstraint?.constant = Theme.replyActionsViewHeight
            moreRepliesViewHeightConstraint?.constant = Theme.moreRepliesViewHeight
        }
        moreRepliesViewHeightConstraint?.constant = data.repliesButtonState == .hidden ?
            0.0 :
            Theme.moreRepliesViewHeight
        updateRepliesButtonTitle(with: data.repliesRawCount)
        moreRepliesView.updateView(with: data.repliesButtonState)
        updateCommentMediaView(with: data)
    }
    
    private func updateCommentMediaView(with dataModel: CommentViewModel) {
        guard !dataModel.isDeletedOrReported() && (dataModel.commentGifUrl != nil || dataModel.commentImage != nil) else {
            commentMediaViewTopConstraint?.constant = dataModel.isDeletedOrReported() ? 0.0 : SPCommonConstants.emptyCommentMediaTopPadding
            commentMediaViewWidthConstraint?.constant = 0
            commentMediaViewHeightConstraint?.constant = 0
            commentMediaView.clearExistingMedia()
            return
        }
        let mediaSize = dataModel.getMediaSize()
        commentMediaView.configureMedia(imageUrl: dataModel.commentImage?.imageUrl, gifUrl: dataModel.commentGifUrl)
        commentMediaViewTopConstraint?.constant = SPCommonConstants.commentMediaTopPadding
        commentMediaViewWidthConstraint?.constant = mediaSize.width
        commentMediaViewHeightConstraint?.constant = mediaSize.height
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        messageView.updateColorsAccordingToStyle()
        userNameView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        avatarView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
        commentLabelView.updateColorsAccordingToStyle()
    }

    private func updateRepliesButtonTitle(with repliesCount: Int?) {
        if let repliesCount = repliesCount, repliesCount == 1 {
            moreRepliesView.collapsedTitle = LocalizationManager.localizedString(key: "View Reply")
            moreRepliesView.expandedTitle = LocalizationManager.localizedString(key: "Hide Reply")
        } else {
            moreRepliesView.collapsedTitle = LocalizationManager.localizedString(key: "View Replies")
            moreRepliesView.expandedTitle = LocalizationManager.localizedString(key: "Hide Replies")
        }
    }
    
    private func updateUserView(with dataModel: CommentViewModel) {
        userNameView.setDeletedOrReported(isDeleted: dataModel.isDeleted, isReported: dataModel.isReported)
        userNameView.setUserName(dataModel.displayName,
                                 badgeTitle: dataModel.badgeTitle,
                                 isLeader: dataModel.showsStar,
                                 contentType: .reply,
                                 isDeleted: dataModel.isDeletedOrReported())
        userNameView.setMoreButton(hidden: dataModel.isDeletedOrReported())
        userNameView.setSubtitle(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? ""
                : LocalizationManager.localizedString(key: "To") + " \(dataModel.replyingToDisplayName!)"
        )
        userNameView.setDate(
            dataModel.replyingToDisplayName?.isEmpty ?? true
                ? dataModel.timestamp
                : " · ".appending(dataModel.timestamp ?? "")
        )
        let userViewHeight = dataModel.badgeTitle == nil ? Theme.userViewCollapsedHeight : Theme.userViewExpandedHeight
        userViewHeightConstraint?.constant = userViewHeight
    }
    
    private func updateActionView(with dataModel: CommentViewModel, isReadOnlyMode: Bool) {
        replyActionsView.setReadOnlyMode(enabled: isReadOnlyMode)
        replyActionsView.setBrandColor(.brandColor)
        replyActionsView.setReplyButton(repliesCount: dataModel.repliesCount, shouldHideButton:  dataModel.depth >= 6)
        replyActionsView.setRankUp(dataModel.rankUp)
        replyActionsView.setRankDown(dataModel.rankDown)
        replyActionsView.setRanked(with: dataModel.rankedByUser)
    }
    
    private func updateAvatarView(with dataModel: CommentViewModel) {
        imageRequest?.cancel()
        avatarView.updateAvatar(image: nil)
        avatarView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        if !dataModel.isDeletedOrReported() {
            imageRequest = UIImage.load(with: dataModel.userAvatar) { [weak self] image, _ in
                self?.avatarView.updateAvatar(image: image)
            }
            avatarView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        } else {
            avatarView.updateOnlineStatus(.offline)
        }
    }
    
    private func updateCommentLabelView(with dataModel: CommentViewModel) {
        if let commentLabel = dataModel.commentLabel,
           dataModel.isDeletedOrReported() == false {
            commentLabelView.setLabel(commentLabelIconUrl: commentLabel.iconUrl, labelColor: commentLabel.color, labelText: commentLabel.text, labelId: commentLabel.id, state: .readOnly)
            commentLabelView.isHidden = false
            commentLabelHeightConstraint?.constant = Theme.commentLabelHeight
        } else {
            commentLabelView.isHidden = true
            commentLabelHeightConstraint?.constant = 0
        }
    }
    
    // MARK: - Private UISetup
    
    private func setupUI() {
        contentView.addSubviews(avatarView, userNameView, commentLabelView, messageView, replyActionsView, moreRepliesView, commentMediaView)
        configureAvatarView()
        configureUserNameView()
        configureCommentLabelView()
        configureMessageView()
        configureReplyActionsView()
        configureMoreRepliesView()
        configureCommentMediaView()
    }
    
    private func configureAvatarView() {
        avatarView.delegate = self
        avatarView.layout {
            $0.leading.equal(to: messageView.leadingAnchor)
            $0.trailing.equal(to: userNameView.leadingAnchor, offsetBy: -Theme.avatarImageViewTrailingOffset)
            $0.centerY.equal(to: userNameView.centerYAnchor)
            $0.height.equal(to: Theme.avatarSideSize)
            $0.width.equal(to: Theme.avatarSideSize)
        }
    }
    
    private func configureCommentMediaView() {
        commentMediaView.layout {
            commentMediaViewTopConstraint = $0.top.equal(to: messageView.bottomAnchor, offsetBy: SPCommonConstants.emptyCommentMediaTopPadding)
            $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.lessThanOrEqual(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            commentMediaViewHeightConstraint = $0.height.equal(to: 0)
            commentMediaViewWidthConstraint = $0.width.equal(to: 0)
        }
    }
    
    private func configureUserNameView() {
        userNameView.delegate = self
        userNameView.layout {
            $0.top.equal(to: contentView.topAnchor, offsetBy: Theme.topOffset)
            $0.trailing.equal(to: contentView.trailingAnchor)
            userViewHeightConstraint = $0.height.equal(to: Theme.userViewCollapsedHeight)
        }
    }
    
    private func configureCommentLabelView() {
        commentLabelView.layout {
            $0.top.equal(to: userNameView.bottomAnchor, offsetBy: 10)
            $0.leading.equal(to: messageView.leadingAnchor)
            commentLabelHeightConstraint = $0.height.equal(to: Theme.commentLabelHeight)
        }
    }
    
    private func configureMessageView() {
        messageView.layout {
            $0.top.equal(to: commentLabelView.bottomAnchor, offsetBy: Theme.messageContainerTopOffset)
            textViewLeadingConstraint = $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func configureReplyActionsView() {
        replyActionsView.delegate = self
        
        replyActionsView.layout {
            $0.top.equal(to: commentMediaView.bottomAnchor)
            $0.leading.equal(to: messageView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            replyActionsViewHeightConstraint = $0.height.equal(to: Theme.replyActionsViewHeight)
        }
    }
    
    private func configureMoreRepliesView() {
        moreRepliesView.delegate = self
        moreRepliesView.layout {
            $0.top.equal(to: replyActionsView.bottomAnchor, offsetBy: Theme.moreRepliesTopOffset)
            $0.leading.equal(to: messageView.leadingAnchor)
            $0.trailing.lessThanOrEqual(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
            moreRepliesViewHeightConstraint = $0.height.equal(to: Theme.moreRepliesViewHeight)
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

extension SPReplyCell: AvatarViewDelegate {
    
    func avatarDidTapped() {
        delegate?.respondToAuthorTap(for: commentId, isAvatarClicked: true)
    }
}

extension SPReplyCell: CommentActionsDelegate {
    
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

extension SPReplyCell: UserNameViewDelegate {
    
    func moreButtonDidTapped(sender: UIButton) {
        delegate?.moreTapped(for: commentId, replyingToID: replyingToId, sender: sender)
    }
    
    func userNameDidTapped() {
        delegate?.respondToAuthorTap(for: commentId, isAvatarClicked: false)
    }
}

extension SPReplyCell: ShowMoreRepliesViewDelegate {
    
    func showHideReplies() {
        if repliesButtonState == .collapsed {
            delegate?.showMoreReplies(for: commentId)
        } else if repliesButtonState == .expanded {
            delegate?.hideReplies(for: commentId)
        }
    }
}

extension SPReplyCell: MessageContainerViewDelegate {
    
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
    
// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let deletedFontSize: CGFloat = 17.0
    static let topOffset: CGFloat = 14.0
    static let bottomOffset: CGFloat = 15.0
    static let leadingOffset: CGFloat = 42.0
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
