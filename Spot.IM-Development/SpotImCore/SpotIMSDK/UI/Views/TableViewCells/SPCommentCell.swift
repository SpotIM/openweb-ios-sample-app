//
//  SPCommentCell.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Alamofire
import WebKit

protocol MessageItemContainable: class {
    var messageView: MessageContainerView { get }
}

extension MessageItemContainable {
    
    func containsChatItem(at point: CGPoint) -> Bool {
        return messageView.frame.contains(point)
    }
}

internal final class SPCommentCell: SPBaseTableViewCell, MessageItemContainable, WKUIDelegate {
    
    weak var delegate: SPCommentCellDelegate?

    let messageView: MessageContainerView = .init()

    private let avatarImageView: SPAvatarView = SPAvatarView()
    private let userNameView: UserNameView = .init()
    private let commentLabelView: CommentLabelView = .init()
    private let replyActionsView: CommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    private let headerView: BaseView = .init()
    private let separatorView: BaseView = .init()
    private let gifWebView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
//    private var commentImageView: UIImageView = .init()
    
    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed
    
    private var replyActionsViewHeightConstraint: NSLayoutConstraint?
    private var moreRepliesViewHeightConstraint: NSLayoutConstraint?
    private var headerViewHeightConstraint: NSLayoutConstraint?
    private var userNameViewTopConstraint: NSLayoutConstraint?
    private var separatorHeightConstraint: NSLayoutConstraint?
    private var separatorLeadingConstraint: NSLayoutConstraint?
    private var separatorTrailingConstraint: NSLayoutConstraint?
    private var commentLabelHeightConstraint: NSLayoutConstraint?
    private var gifWebViewHeightConstraint: NSLayoutConstraint?
    private var gifWebViewWidthConstraint: NSLayoutConstraint?
    private var gifWebViewTopConstraint: NSLayoutConstraint?

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
        lineLimit: Int
    ) {
        commentId = data.commentId
        replyingToId = data.replyingToCommentId
        repliesButtonState = data.repliesButtonState
        messageView.delegate = self
        
        updateUserView(with: data)
        updateActionView(with: data)
        updateAvatarView(with: data)
        updateHeaderView(with: data, shouldShowHeader: shouldShowHeader)
        updateMoreRepliesView(with: data, minimumVisibleReplies: minimumVisibleReplies)
        updateMessageView(with: data, clipToLine: lineLimit)
        updateGifWebView(with: data)
//        updateCommentImageView(with: data)
        updateCommentLabelView(with: data)
    }

    // MARK: - Private Methods - View setup

    private func setupUI() {
        contentView.addSubviews(headerView,
                                avatarImageView,
                                userNameView,
                                commentLabelView,
                                messageView,
                                gifWebView,
                                replyActionsView,
                                moreRepliesView)
        configureHeaderView()
        configureAvatarView()
        configureUserNameView()
        configureCommentLabelView()
        configureMessageView()
        configureGifWebView()
        configureReplyActionsView()
        configureMoreRepliesView()
    }

    private func configureHeaderView() {
        separatorView.backgroundColor = .spSeparator
        headerView.addSubview(separatorView)
        separatorView.layout {
            $0.centerX.equal(to: headerView.centerXAnchor)
            $0.centerY.equal(to: headerView.centerYAnchor)
            separatorLeadingConstraint = $0.leading.equal(to: headerView.leadingAnchor, offsetBy: 0.0)
            separatorTrailingConstraint = $0.trailing.equal(to: headerView.trailingAnchor, offsetBy: 0.0)
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
    
    private func configureGifWebView() {
        gifWebView.layer.cornerRadius = 6
        gifWebView.layer.masksToBounds = true
        gifWebView.scrollView.isScrollEnabled = false
        gifWebView.isUserInteractionEnabled = false
        gifWebView.layout {
            gifWebViewHeightConstraint = $0.height.equal(to: 0)
            gifWebViewWidthConstraint = $0.width.greaterThanOrEqual(to: 0)
            gifWebViewTopConstraint = $0.top.equal(to: messageView.bottomAnchor, offsetBy: 19.0)
            $0.leading.greaterThanOrEqual(to: contentView.leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.lessThanOrEqual(to: contentView.trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func configureReplyActionsView() {
        replyActionsView.delegate = self
        
        replyActionsView.layout {
            $0.top.equal(to: gifWebView.bottomAnchor)
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
        userNameView.setDeleted(dataModel.isDeleted)
        
        userNameView.setUserName(
            dataModel.displayName,
            badgeTitle: dataModel.badgeTitle,
            isLeader: dataModel.showsStar,
            contentType: .reply,
            isDeleted: dataModel.isDeleted)
        userNameView.setMoreButton(hidden: dataModel.isDeleted)
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
           dataModel.isDeleted == false {
            commentLabelView.setLabel(commentLabelIconUrl: commentLabel.iconUrl, labelColor: commentLabel.color, labelText: commentLabel.text, labelId: commentLabel.id, state: .readOnly)
            commentLabelView.isHidden = false
            commentLabelHeightConstraint?.constant = Theme.commentLabelHeight
        } else {
            commentLabelHeightConstraint?.constant = 0
            commentLabelView.isHidden = true
        }
    }
    
    private func updateActionView(with dataModel: CommentViewModel) {
        replyActionsView.setBrandColor(.brandColor)
        replyActionsView.setRepliesCount(dataModel.repliesCount)
        replyActionsView.setRankUp(dataModel.rankUp)
        replyActionsView.setRankDown(dataModel.rankDown)
        replyActionsView.setRanked(with: dataModel.rankedByUser)
        replyActionsViewHeightConstraint?.constant = dataModel.isDeleted ? 0.0 : Theme.replyActionsViewHeight
    }
    
    private func updateHeaderView(with dataModel: CommentViewModel, shouldShowHeader: Bool) {
        headerViewHeightConstraint?.constant = shouldShowHeader ? 7.0 : 0.0
        separatorHeightConstraint?.constant = shouldShowHeader ? (dataModel.isCollapsed ? 1.0 : 7.0) : 0.0
        separatorLeadingConstraint?.constant = dataModel.isCollapsed ? Theme.leadingOffset : 0.0
        separatorTrailingConstraint?.constant = dataModel.isCollapsed ? -Theme.leadingOffset : 0.0

        separatorView.backgroundColor = dataModel.isCollapsed ? .spSeparator : .spSeparator4
    }
    
    private func updateAvatarView(with dataModel: CommentViewModel) {
        imageRequest?.cancel()
        avatarImageView.updateAvatar(image: nil)
        avatarImageView.updateOnlineStatus(dataModel.showsOnline ? .online : .offline)
        if !dataModel.isDeleted {
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

    private func updateMessageView(with dataModel: CommentViewModel, clipToLine: Int) {
        if messageView.frame.width < 1 {
            setNeedsLayout()
            layoutIfNeeded()
        }
        if dataModel.isDeleted {
            messageView.setMessage(
                "",
                attributes: attributes(isDeleted: true),
                isCollapsed: dataModel.commentTextCollapsed)
        } else {
            messageView.setMessage(dataModel.commentText ?? "",
                                   attributes: attributes(isDeleted: false),
                                   clipToLine: clipToLine,
                                   width: dataModel.textWidth(),
                                   isCollapsed: dataModel.commentTextCollapsed)
        }
    }
    
    private func updateGifWebView(with dataModel: CommentViewModel) {
        // gif
        gifWebView.uiDelegate = self
        if let url = dataModel.commentGifUrl {
            // set url into html template
            let htmlFile = Bundle.main.path(forResource: "gifWebViewTemplate", ofType: "html")
            var htmlString = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            htmlString = htmlString?.replacingOccurrences(of: "IMAGE", with: url)
            // set placeholder image
            let placeholderPath = Bundle.main.resourcePath ?? "" + "image_placeholder/image_placeholder.png"
            htmlString = htmlString?.replacingOccurrences(of: "PLACEHOLDER", with: placeholderPath )
            gifWebView.loadHTMLString(htmlString!, baseURL: nil)
            // calculate GIF width according to height ratio
            let (height, width) = dataModel.calculateGifSize()
            gifWebViewHeightConstraint?.constant = CGFloat(height)
            gifWebViewWidthConstraint?.constant = CGFloat(width)
            gifWebViewTopConstraint?.constant = 19
        } else {
            gifWebViewHeightConstraint?.constant = 0
            gifWebViewWidthConstraint?.constant = 0
            gifWebViewTopConstraint?.constant = 12
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
        delegate?.moreTapped(for: commentId, sender: sender)
    }
    
    func userNameDidTapped() {
        delegate?.respondToAuthorTap(for: commentId)
    }
}

extension SPCommentCell: AvatarViewDelegate {
    
    func avatarDidTapped() {
        delegate?.respondToAuthorTap(for: commentId)
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
    }

    func readLessTappedInMessageContainer(view: MessageContainerView) {
        delegate?.showLessText(for: commentId)
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

protocol SPCommentCellDelegate: class {
    func showMoreReplies(for commentId: String?)
    func hideReplies(for commentId: String?)
    func changeRank(with change: SPRankChange, for commentId: String?, with replyingToID: String?)
    func replyTapped(for commentId: String?)
    func moreTapped(for commentId: String?, sender: UIButton)
    func respondToAuthorTap(for commentId: String?)
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
    static let commentMediaHeight: CGFloat = 226.0
}
