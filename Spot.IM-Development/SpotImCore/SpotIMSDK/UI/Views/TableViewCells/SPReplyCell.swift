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
    private let commentLabelsView: CommentLabelView = .init()
    private let replyActionsView: CommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    
    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed
    
    private var replyActionsViewHeightConstraint: NSLayoutConstraint?
    private var moreRepliesViewHeightConstraint: NSLayoutConstraint?
    private var userViewHeightConstraint: NSLayoutConstraint?
    private var textViewLeadingConstraint: NSLayoutConstraint?

    private var imageRequest: DataRequest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func configure(with data: CommentViewModel, lineLimit: Int) {
        commentId = data.commentId
        replyingToId = data.replyingToCommentId
        repliesButtonState = data.repliesButtonState
        updateUserView(with: data)
        updateActionView(with: data)
        updateAvatarView(with: data)
        updateCommentLabelView(with: data)
        messageView.delegate = self
        
        textViewLeadingConstraint?.constant = data.depthOffset()
        if data.isDeleted {
            messageView.setMessage("", attributes: attributes(isDeleted: true), isCollapsed: data.commentTextCollapsed)
            replyActionsViewHeightConstraint?.constant = 0.0
            moreRepliesViewHeightConstraint?.constant = 0.0
        } else {
            messageView.setMessage(
                data.commentText ?? "",
                attributes: attributes(isDeleted: false),
                clipToLine: lineLimit,
                width: data.textWidth(),
                isCollapsed: data.commentTextCollapsed
            )
            replyActionsViewHeightConstraint?.constant = Theme.replyActionsViewHeight
            moreRepliesViewHeightConstraint?.constant = Theme.moreRepliesViewHeight
        }
        moreRepliesViewHeightConstraint?.constant = data.repliesButtonState == .hidden ?
            0.0 :
            Theme.moreRepliesViewHeight
        updateRepliesButtonTitle(with: data.repliesRawCount)
        moreRepliesView.updateView(with: data.repliesButtonState)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        messageView.updateColorsAccordingToStyle()
        userNameView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        avatarView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
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
        userNameView.setDeleted(dataModel.isDeleted)
        userNameView.setUserName(dataModel.displayName,
                                 badgeTitle: dataModel.badgeTitle,
                                 isLeader: dataModel.showsStar,
                                 contentType: .reply,
                                 isDeleted: dataModel.isDeleted)
        userNameView.setMoreButton(hidden: dataModel.isDeleted)
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
    
    private func updateActionView(with dataModel: CommentViewModel) {
        replyActionsView.setBrandColor(.brandColor)
        replyActionsView.setRepliesCount(dataModel.repliesCount)
        replyActionsView.setRankUp(dataModel.rankUp)
        replyActionsView.setRankDown(dataModel.rankDown)
        replyActionsView.setRanked(with: dataModel.rankedByUser)
        replyActionsView.setReplyButton(enabled: dataModel.depth < 6)
    }
    
    private func updateAvatarView(with dataModel: CommentViewModel) {
        imageRequest?.cancel()
        avatarView.updateAvatar(image: nil)
        avatarView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        if !dataModel.isDeleted {
            imageRequest = UIImage.load(with: dataModel.userAvatar) { [weak self] image, _ in
                self?.avatarView.updateAvatar(image: image)
            }
            avatarView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        } else {
            avatarView.updateOnlineStatus(.offline)
        }
    }
    
    private func updateCommentLabelView(with dataModel: CommentViewModel) {
        if let labelIconUrl = dataModel.commentLabelIconUrl, let commentLabelText = dataModel.commentLabelText, let commentLabelColor = dataModel.commentLabelColor {
            commentLabelsView.setLabel(commentLabelIconUrl: labelIconUrl, rgbColor: commentLabelColor, labelText: commentLabelText, state: .readOnly)
        } else {
            commentLabelsView.setLabel(commentLabelIconUrl: nil, rgbColor: nil, labelText: nil, state: .hidden)
        }
    }
    
    // MARK: - Private UISetup
    
    private func setupUI() {
        contentView.addSubviews(avatarView, userNameView, commentLabelsView, messageView, replyActionsView, moreRepliesView)
        configureAvatarView()
        configureUserNameView()
        configureCommentLabelsView()
        configureMessageView()
        configureReplyActionsView()
        configureMoreRepliesView()
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
    
    private func configureUserNameView() {
        userNameView.delegate = self
        userNameView.layout {
            $0.top.equal(to: contentView.topAnchor, offsetBy: Theme.topOffset)
            $0.trailing.equal(to: contentView.trailingAnchor)
            userViewHeightConstraint = $0.height.equal(to: Theme.userViewCollapsedHeight)
        }
    }
    
    private func configureCommentLabelsView() {
        commentLabelsView.layout {
            $0.top.equal(to: userNameView.bottomAnchor, offsetBy: 10)
            $0.leading.equal(to: messageView.leadingAnchor)
        }
    }
    
    private func configureMessageView() {
        messageView.layout {
            $0.top.equal(to: commentLabelsView.bottomAnchor, offsetBy: Theme.messageContainerTopOffset)
            textViewLeadingConstraint = $0.leading.equal(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func configureReplyActionsView() {
        replyActionsView.delegate = self
        
        replyActionsView.layout {
            $0.top.equal(to: messageView.bottomAnchor)
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
        delegate?.respondToAuthorTap(for: commentId)
    }
}

extension SPReplyCell: CommentActionsDelegate {
    
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

extension SPReplyCell: UserNameViewDelegate {
    
    func moreButtonDidTapped(sender: UIButton) {
        delegate?.moreTapped(for: commentId, sender: sender)
    }
    
    func userNameDidTapped() {
        delegate?.respondToAuthorTap(for: commentId)
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
        UIApplication.shared.open(url)
    }
    
    func readMoreTappedInMessageContainer(view: MessageContainerView) {
        delegate?.showMoreText(for: commentId)
    }

    func readLessTappedInMessageContainer(view: MessageContainerView) {
        delegate?.showLessText(for: commentId)
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
}
