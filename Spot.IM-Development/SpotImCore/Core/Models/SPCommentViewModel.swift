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
    var rankUp: Int = 0
    var rankDown: Int = 0
    var repliesRawCount: Int?
    var repliesCount: String?
    var depth: Int = 0
    var commentLabel: CommentLabel?
    var commentGifUrl: String?
    var commentImage: CommentImage?
    var commentMediaHeight: Float?
    var commentMediaWidth: Float?
    
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
        userImageURL: URL? = nil,
        commentImageURL: URL? = nil) {

        isDeleted = comment.deleted
        authorId = comment.userId
        commentId = comment.id
        rootCommentId = comment.rootComment
        hasOffset = comment.isReply
        parentCommentId = comment.parentId
        depth = comment.depth ?? 0
        
        
        if let commentLabelConfig = getCommentLabelFromConfig(comment: comment),
           let commentLabelColor = UIColor.color(rgb: commentLabelConfig.color),
           let commentLabelIconUrl = commentLabelConfig.getIconUrl() {
            commentLabel = CommentLabel(id: commentLabelConfig.id ,text: commentLabelConfig.text, iconUrl: commentLabelIconUrl, color: commentLabelColor)
        }
        
        if let gif = comment.gif {
            commentGifUrl = gif.originalUrl
            (self.commentMediaHeight, self.commentMediaWidth) = self.calculateMediaSize(mediaHeight: gif.previewHeight, mediaWidth: gif.previewWidth)
        }
        
        if let image = comment.image, let commentImageURL = commentImageURL {
            commentImage = CommentImage(id: image.imageId, height: image.originalHeight, width: image.originalWidth, imageUrl: commentImageURL)
            (self.commentMediaHeight, self.commentMediaWidth) = self.calculateMediaSize(mediaHeight: image.originalHeight, mediaWidth: image.originalWidth)
        }
        
        
        if comment.hasNext {
            repliesButtonState = .collapsed
        } else {
            repliesButtonState = .hidden
        }
        
        switch comment.content?.first {
        case .text(let htmlText):
            if let data = htmlText.text.data(using: String.Encoding.unicode, allowLossyConversion: false),
               let attributedHtmlString = try? NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) {
                commentText = attributedHtmlString.string
                break
            }
        default:
            commentText = "no text"
        }

        if let time = comment.writtenAt {
            timestamp = Date(timeIntervalSince1970: time).timeAgo()
        }

        if let repliesCount = comment.repliesCount, repliesCount > 0 {
            repliesRawCount = comment.repliesCount
            self.repliesCount = repliesCount.kmFormatted
        }

        if let ranksUp = comment.rank?.ranksUp, ranksUp > 0 {
            rankUp = ranksUp
        }
        if let ranksDown = comment.rank?.ranksDown, ranksDown > 0 {
            rankDown = ranksDown
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
                badgeTitle = nil
            } 
        }

        self.replyingToCommentId = replyingToCommentId
        self.replyingToDisplayName = replyingToDisplayName
    }

    func textWidth() -> CGFloat {
        let leadingOffset: CGFloat = depthOffset()
        let textWidth = UIScreen.main.bounds.width - leadingOffset - Theme.trailingOffset
        
        return textWidth
    }
    
    func calculateMediaSize(mediaHeight: Int, mediaWidth: Int) -> (Float, Float) {
        let leadingOffset: CGFloat = depthOffset()
        let maxWidth = UIScreen.main.bounds.width - leadingOffset - Theme.trailingOffset
        
        // calculate media width according to height ratio
        var height = Theme.commentMediaMaxHeight
        var ratio: Float = Float(height / Float(mediaHeight))
        var width = ratio * Float(mediaWidth)
        // if width > cell - recalculate size
        if width > Float(maxWidth) {
            width = (Float)(maxWidth)
            ratio = Float(width / Float(mediaWidth))
            height = (ratio * Float(mediaHeight))
        }
        
        return (height, width)
    }
    
    func height(with lineLimit: Int, isLastInSection: Bool = false) -> CGFloat {
        let width = textWidth()
        let attributedMessage = NSAttributedString(string: message(), attributes: attributes(isDeleted: isDeleted))
        let clippedMessage = attributedMessage.clippedToLine(
            index: lineLimit,
            width: width,
            isCollapsed: commentTextCollapsed
        )
        let textHeight: CGFloat = clippedMessage.string.isEmpty ?
            0.0 : clippedMessage.height(withConstrainedWidth: width)
        
        // media extra height includes - media acual heigh + media extra padding
        let mediaHeight: CGFloat = commentMediaHeight == nil ? 0.0 : CGFloat(commentMediaHeight! + Float(SPCommonConstants.commentMediaTopPadding - SPCommonConstants.emptyCommentMediaTopPadding))
        
        let moreRepliesHeight = repliesButtonState == .hidden ?
            0.0 : Theme.moreRepliesViewHeight + Theme.moreRepliesTopOffset

        let userViewHeight: CGFloat = badgeTitle == nil ? Theme.userViewCollapsedHeight : Theme.userViewExpandedHeight
        let commentLabelHeight: CGFloat = Theme.commentLabelViewHeight
        
        let lastInSectionOffset = isLastInSection ? Theme.lastInSectionOffset : 0
        let deletedOffset = isDeleted ? Theme.bottomOffset : lastInSectionOffset
        let repliesButtonExpandedOffset = repliesButtonState == .hidden ? deletedOffset : Theme.bottomOffset
        
        let height: CGFloat = (isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset)
            + (isCollapsed ? 40.0 : repliesButtonExpandedOffset)
            + userViewHeight
            + (isDeleted ? 0.0 : Theme.messageContainerTopOffset)
            + (isDeleted ? 0.0 : Theme.replyActionsViewHeight)
            + textHeight
            + (isCollapsed ? 0.0 : moreRepliesHeight)
            + (commentLabel == nil ? 0.0 : commentLabelHeight)
            + mediaHeight

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
        static let lastInSectionOffset: CGFloat = 19.0
        static let commentLabelViewHeight: CGFloat = 28.0
        static let commentMediaMaxHeight: Float = 226.0
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
    
    private func getCommentLabelFromConfig(comment: SPComment) -> SPLabelConfiguration? {
        // cross given commentLabels to appConfig labels
        if let sharedConfig = SPConfigsDataSource.appConfig?.shared,
           sharedConfig.enableCommentLabels == true,
           let commentLabels = comment.additionalData?.labels,
           let labelIds = commentLabels.ids, labelIds.count > 0,
           let section = commentLabels.section,
           let commentLabelsConfig = sharedConfig.commentLabels,
           let sectionLabels = commentLabelsConfig[section] {
            // only the first comment label is shown
            return sectionLabels.getLabelById(labelId: labelIds[0])
        }
        return nil
    }

}

struct CommentLabel {
    var id: String
    var text: String
    var iconUrl: URL
    var color: UIColor
}

struct CommentImage {
    var id: String
    var height: Int
    var width: Int
    var imageUrl: URL
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
