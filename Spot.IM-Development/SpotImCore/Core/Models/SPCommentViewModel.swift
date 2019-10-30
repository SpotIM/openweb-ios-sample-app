//
//  SPCommentViewModel.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal struct CommentViewModel {

        var authorId: String?
        var commentId: String?
        var parentCommentId: String?
        var rootCommentId: String?
        var displayName: String?
        var userAvatar: URL?
        var timestamp: String?
        var commentText: String?
        var rankedByUser: Int = 0
        var rankUp: String?
        var rankDown: String?
        var repliesRawCount: Int?
        var repliesCount: String?
        var depth: Int = 0
        
        var replyingToDisplayName: String?
        var replyingToCommentId: String?
        
        var showsOnline: Bool = false
        var hasOffset: Bool = false
        var isDeleted: Bool = false
        // helper property for array cleaning
        var shouldBeRemoved: Bool = false
        var repliesButtonState: RepliesButtonState = .collapsed
        var isCollapsed: Bool = false
        var showsStar: Bool = false
        var badgeTitle: String?
        var badgeIsGamification: Bool = false
        var commentTextCollapsed: Bool = true
        
        var brandColor: UIColor = .brandColor

        var isRoot: Bool {
            guard let id = commentId, !id.isEmpty else { return false }
            
            return id == rootCommentId
        }

    init(
        with comment: SPComment,
        replyingToCommentId: String? = nil,
        replyingToDisplayName: String? = nil,
        color: UIColor? = nil,
        user: SPUser? = nil,
        userImageURL: URL? = nil) {

        isDeleted = comment.deleted
        authorId = comment.userId
        commentId = comment.id
        rootCommentId = comment.rootComment
        hasOffset = comment.isReply
        parentCommentId = comment.parentId
        depth = comment.depth ?? 0

        if comment.hasNext {
            repliesButtonState = .collapsed
        } else {
            repliesButtonState = .hidden
        }

        // FIXME: (Fedin) first content could be not text
        commentText = "\(comment.content?.first?.text ?? "no text")"

        if let time = comment.writtenAt {
            timestamp = Date(timeIntervalSince1970: time).timeAgo()
        }

        if let repliesCount = comment.repliesCount, repliesCount > 0 {
            repliesRawCount = comment.repliesCount
            self.repliesCount = repliesCount.kmFormatted
        }

        if let ranksUp = comment.rank?.ranksUp, ranksUp > 0 {
            rankUp = ranksUp.kmFormatted
        }
        if let ranksDown = comment.rank?.ranksDown, ranksDown > 0 {
            rankDown = ranksDown.kmFormatted
        }

        rankedByUser = comment.rank?.rankedByCurrentUser ?? 0

        if let brandColor = color {
            self.brandColor = brandColor
        }

        if let user = user {
            showsOnline = user.online ?? false
            displayName = user.displayName
            userAvatar = userImageURL
            if user.isAuthority {
                badgeIsGamification = false
                showsStar = false
                badgeTitle = user.authorityTitle
            } else if user.hasGamification {
                badgeIsGamification = true
                showsStar = true
                badgeTitle = user.badgeType?.capitalized
            }
        }

        self.replyingToCommentId = replyingToCommentId
        self.replyingToDisplayName = replyingToDisplayName
    }
        
    func height(with lineLimit: Int) -> CGFloat {
            let leadingOffset: CGFloat = depthOffset()
            let textWidth = UIScreen.main.bounds.width - leadingOffset - Theme.trailingOffset
            let attributedMessage = NSAttributedString(string: message(), attributes: attributes(isDeleted: isDeleted))
            let clippedMessage = attributedMessage.clippedToLine(
                index: lineLimit,
                width: textWidth,
                isCollapsed: commentTextCollapsed
            )
            let textHeight: CGFloat = clippedMessage.string.isEmpty ?
                0.0 : clippedMessage.height(withConstrainedWidth: textWidth)

            let moreRepliesHeight = repliesButtonState == .hidden ?
                0.0 : Theme.moreRepliesViewHeight + Theme.moreRepliesTopOffset

            let userViewHeight: CGFloat = badgeTitle == nil ?
                Theme.userViewCollapsedHeight : Theme.userViewExpandedHeight
            let deletedOffset = isDeleted ? Theme.bottomOffset : 0.0
            let repliesButtonExpandedOffset = repliesButtonState == .hidden ? deletedOffset : Theme.bottomOffset

            let height: CGFloat = (isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset)
                + (isCollapsed ? 40.0 : repliesButtonExpandedOffset)
                + userViewHeight
                + (isDeleted ? 0.0 : Theme.messageContainerTopOffset)
                + (isDeleted ? 0.0 : Theme.replyActionsViewHeight)
                + textHeight
                + (isCollapsed ? 0.0 : moreRepliesHeight)
            
            return height
        }
        
        func depthOffset() -> CGFloat {
            switch depth {
            case 0: return Theme.leadingCommentOffset
            case 1: return Theme.leadingCommentOffset + 25.0
            case 2: return Theme.leadingCommentOffset + 40.0
            default: return Theme.leadingCommentOffset + 55.0
            }
        }
        
        private enum Theme {
            static let fontSize: CGFloat = 16.0
            static let deletedFontSize: CGFloat = 17.0
            static let topOffset: CGFloat = 14.0
            static let topCollapsedOffset: CGFloat = 22.0
            static let bottomOffset: CGFloat = 15.0
            static let leadingReplyOffset: CGFloat = 42.0
            static let leadingCommentOffset: CGFloat = 16.0
            static let trailingOffset: CGFloat = 16.0
            static let messageContainerTopOffset: CGFloat = 14.0
            static let userViewCollapsedHeight: CGFloat = 44.0
            static let userViewExpandedHeight: CGFloat = 69.0
            static let replyActionsViewHeight: CGFloat = 49.0
            static let moreRepliesViewHeight: CGFloat = 31.0
            static let moreRepliesTopOffset: CGFloat = 12.0
        }
        
        private func message() -> String {
            if isDeleted {
                return ""
            } else {
                return commentText ?? ""
            }
        }
        
        private func attributes(isDeleted: Bool) -> [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 0
            paragraphStyle.lineSpacing = 3.5
            
            var attributes: [NSAttributedString.Key: Any]
            if !isDeleted {
                attributes = [
                    .foregroundColor: UIColor.charcoalGrey,
                    .font: UIFont.preferred(style: .regular, of: Theme.fontSize),
                    .paragraphStyle: paragraphStyle
                ]
            } else {
                attributes = [
                    .foregroundColor: UIColor.steelGrey,
                    .font: UIFont.openSans(style: .regularItalic, of: Theme.deletedFontSize),
                    .paragraphStyle: paragraphStyle
                ]
            }
            
            return attributes
        }
        
    }

// MARK: - Theme

private enum Theme {
    
    static let fontSize: CGFloat = 16.0
    static let deletedFontSize: CGFloat = 17.0
    static let topOffset: CGFloat = 14.0
    static let bottomOffset: CGFloat = 15.0
    static let leadingCommentOffset: CGFloat = 16.0
    static let trailingOffset: CGFloat = 16.0
    static let messageContainerTopOffset: CGFloat = 14.0
    static let userViewCollapsedHeight: CGFloat = 44.0
    static let userViewExpandedHeight: CGFloat = 69.0
    static let replyActionsViewHeight: CGFloat = 49.0
    static let moreRepliesViewHeight: CGFloat = 31.0
    static let moreRepliesTopOffset: CGFloat = 12.0
}
