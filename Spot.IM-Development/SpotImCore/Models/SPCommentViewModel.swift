//
//  SPCommentViewModel.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

internal struct CommentViewModel {
    
    unowned var conversationModel: SPMainConversationModel?

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
    var commentLabels: [CommentLabel]?
    var commentGifUrl: String?
    var commentImage: CommentImage?
    private var commentMediaOriginalHeight: Int?
    private var commentMediaOriginalWidth: Int?
    
    var replyingToDisplayName: String?
    var replyingToCommentId: String?

    private (set) var showsOnline: Bool = false
    var hasOffset: Bool = false
    private (set) var isDeleted: Bool = false
    var isReported: Bool = false
    var isEdited: Bool = false
    // helper property for array cleaning
    var shouldBeRemoved: Bool = false
    var repliesButtonState: RepliesButtonState = .collapsed
    var isCollapsed: Bool = false
    var badgeTitle: String?
    var commentTextCollapsed: Bool = true
    var showStatusIndicator: Bool = false
    var anyHiddenReply: Bool = false

    var brandColor: UIColor = .brandColor

    var isRoot: Bool {
        guard let id = commentId, !id.isEmpty else { return false }

        return id == rootCommentId
    }
    
    let commentUserVM: OWCommentUserViewModeling
    let commentActionsVM: OWCommentActionsViewModeling = OWCommentActionsViewModel()
    let statusIndicationVM: OWCommentStatusIndicationViewModeling = OWCommentStatusIndicationViewModel()

    init(
        with comment: SPComment,
        replyingToCommentId: String? = nil,
        replyingToDisplayName: String? = nil,
        color: UIColor? = nil,
        user: SPUser? = nil,
        imageProvider: SPImageProvider? = nil) {
        
        commentUserVM = OWCommentUserViewModel(user: user, imageProvider: imageProvider)
        isDeleted = comment.deleted
        isEdited = comment.edited
        authorId = comment.userId
        commentId = comment.id
        rootCommentId = comment.rootComment
        hasOffset = comment.isReply
        parentCommentId = comment.parentId
        depth = comment.depth ?? 0
        
        if let commentId = commentId {
            isReported = SPUserSessionHolder.session.reportedComments[commentId] ?? false
        }
        
        if let commentLabelsConfig = getCommentLabelsFromConfig(comment: comment) {
            commentLabels = []
            for config in commentLabelsConfig {
                if let commentLabelColor = UIColor.color(rgb: config.color),
                   let commentLabelIconUrl = config.getIconUrl()
                {
                    commentLabels?.append(
                        CommentLabel(id: config.id,
                                     text: config.text,
                                     iconUrl: commentLabelIconUrl,
                                     color: commentLabelColor
                                    )
                    )
                }
            }
        }
            
        
        if let gif = comment.gif {
            commentGifUrl = gif.originalUrl
            self.commentMediaOriginalHeight = gif.previewHeight
            self.commentMediaOriginalWidth = gif.previewWidth
        }
        
        if let image = comment.image,
            let commentImageURL = imageProvider?.imageURL(with: comment.image?.imageId, size: nil) {
            commentImage = CommentImage(id: image.imageId, height: image.originalHeight, width: image.originalWidth, imageUrl: commentImageURL)
            self.commentMediaOriginalHeight = image.originalHeight
            self.commentMediaOriginalWidth = image.originalWidth
        }
        
        anyHiddenReply = 1 <= depth && (comment.replies?.count ?? 0 > 0)

        if comment.hasNext || anyHiddenReply {
            repliesButtonState = .collapsed
        } else {
            repliesButtonState = .hidden
        }
        
        if let htmlText = comment.text,
           let commentText = getCommentTextFromHtmlString(htmlString: htmlText.text) {
            self.commentText = commentText
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
            userAvatar = imageProvider?.imageURL(with: user.imageId, size: nil)
            badgeTitle = getUserBadgeUsingConfig(user: user)?.uppercased()
        }

        self.replyingToCommentId = replyingToCommentId
        self.replyingToDisplayName = replyingToDisplayName
            
        self.commentUserVM.inputs.configure(with: self)
        updateCommentActionsVM()
        if let status = comment.status,
           comment.userId == SPUserSessionHolder.session.user?.id,
           !comment.published,
           !comment.deleted, (comment.status == .reject || comment.status == .block || comment.status == .requireApproval || comment.status == .pending) {
            showStatusIndicator = true
            statusIndicationVM.inputs.configure(with: status, isStrictMode: comment.strictMode ?? false, containerWidth: textWidth())
        } else {
            showStatusIndicator = false
        }
    }
    
    func getCommentTextFromHtmlString(htmlString: String) -> String? {
        if let attributedHtmlString = htmlString.htmlToMutableAttributedString {
            return attributedHtmlString.string
        } else {
            SPDefaultFailureReporter.shared.report(error: .generalError(.encodingHtmlError(onCommentId: self.commentId, parentId: self.parentCommentId)))
            return nil
        }
    }

    func textWidth() -> CGFloat {
        let leadingOffset: CGFloat = depthOffset()
        var notchOffset = 0
        if #available(iOS 11.0, *), UIDevice.current.orientation.isLandscape {
            notchOffset = Int((UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0) + (UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0))
        }
        let textWidth = SPUIWindow.frame.width - leadingOffset - Theme.trailingOffset - CGFloat(notchOffset)
        
        return textWidth
    }
    
    // check if userName & badge texts should be in one row or two
    func isUsernameOneRow() -> Bool {
        let leadingOffset: CGFloat = depthOffset()
        let lineWidth = SPUIWindow.frame.width - leadingOffset - Theme.trailingOffset - Theme.avatarWidth - Theme.usernameTrailing
        
        let attributedMessage = NSAttributedString(string: (displayName ?? "") + (badgeTitle ?? "") , attributes: [.font: UIFont.preferred(style: .medium, of: Theme.fontSize)])
        
        return attributedMessage.width(withConstrainedHeight: Theme.usernameLineHeight) < lineWidth
    }
    
    func usernameViewHeight() -> CGFloat {
        return isUsernameOneRow() ? Theme.userViewCollapsedHeight : Theme.userViewExpandedHeight
    }
    
    func getMediaSize() -> CGSize {
        guard let mediaHeight = commentMediaOriginalHeight,
              let mediaWidth = commentMediaOriginalWidth
        else { return CGSize(width: 0, height: 0) }
        let leadingOffset: CGFloat = depthOffset()
        let maxWidth = SPUIWindow.frame.width - leadingOffset - Theme.trailingOffset
        
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
        
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    func height(with lineLimit: Int, isLastInSection: Bool = false) -> CGFloat {
        let width = textWidth()
        let attributedMessage = NSAttributedString(string: message(), attributes: attributes(isDeleted: isDeletedOrReported()))
        let clippedMessage = attributedMessage.clippedToLine(
            index: lineLimit,
            width: width,
            clippedTextSettings: SPClippedTextSettings(
                collapsed: commentTextCollapsed,
                edited: isEdited
            )
        )
        let isEmptyComment = clippedMessage.string.isEmpty
        let textHeight: CGFloat = isEmptyComment ?
            0.0 : clippedMessage.height(withConstrainedWidth: width)
        
        // media extra height includes - media acual heigh + media extra padding
        let mediaHeight = CGFloat(Float(getMediaSize().height) + (isEmptyComment ? Float(SPCommonConstants.emptyCommentMediaTopPadding) : Float(SPCommonConstants.commentMediaTopPadding)))
        
        let moreRepliesHeight = repliesButtonState == .hidden ?
            0.0 : Theme.moreRepliesViewHeight + Theme.moreRepliesTopOffset

        let userViewHeight: CGFloat = usernameViewHeight()
        let commentLabelHeight: CGFloat = Theme.commentLabelViewHeight
        
        let lastInSectionOffset = isLastInSection ? Theme.lastInSectionOffset : 0
        let deletedOffset = isDeletedOrReported() ? Theme.bottomOffset : lastInSectionOffset
        let repliesButtonExpandedOffset = repliesButtonState == .hidden ? deletedOffset : Theme.bottomOffset
        
        let statusIndicationHeight: CGFloat = showStatusIndicator ? (statusIndicationVM.outputs.indicationHeight + 16) : 0
        
        let height: CGFloat = (isCollapsed ? Theme.topCollapsedOffset : Theme.topOffset)
            + (isCollapsed ? 40.0 : repliesButtonExpandedOffset)
            + userViewHeight
            + (isDeletedOrReported() ? 0.0 : Theme.messageContainerTopOffset)
            + (isDeletedOrReported() ? 0.0 : Theme.replyActionsViewHeight)
            + textHeight
            + (isCollapsed ? 0.0 : moreRepliesHeight)
            + ((isDeletedOrReported() || commentLabels == nil) ? 0.0 : commentLabelHeight)
            + (isDeletedOrReported() ? 0.0 : mediaHeight)
            + statusIndicationHeight

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
    
    func isDeletedOrReported() -> Bool {
        return isDeleted || isReported
    }
    
    func isAReply() -> Bool {
        return replyingToCommentId != nil
    }
    
    func updateCommentActionsVM() {
        let model = OWCommentVotingModel(rankUpCount: rankUp, rankDownCount: rankDown, rankedByUserValue: rankedByUser)
        self.commentActionsVM.inputs.configure(with: model)
    }
    
    mutating func setIsDeleted(isDeleted: Bool) {
        self.isDeleted = isDeleted
        // hide status indicator after deleting a comment
        if isDeleted {
            self.showStatusIndicator = false
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
        static let replyActionsViewHeight: CGFloat = 32.0
        static let moreRepliesViewHeight: CGFloat = 31.0
        static let moreRepliesTopOffset: CGFloat = 12.0
        static let lastInSectionOffset: CGFloat = 19.0
        static let commentLabelViewHeight: CGFloat = 28.0
        static let commentMediaMaxHeight: Float = 226.0
        static let avatarWidth: CGFloat = 44
        static let usernameTrailing: CGFloat = 25
        static let usernameLineHeight: CGFloat = 19
    }

    private func message() -> String {
        if isDeletedOrReported() {
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
    
    private func getCommentLabelsFromConfig(comment: SPComment) -> [SPLabelConfiguration]? {
        // cross given commentLabels to appConfig labels
        if let sharedConfig = SPConfigsDataSource.appConfig?.shared,
           sharedConfig.enableCommentLabels == true,
           let commentLabels = comment.additionalData?.labels,
           let labelIds = commentLabels.ids, labelIds.count > 0,
           let section = commentLabels.section,
           let commentLabelsConfig = sharedConfig.commentLabels,
           let sectionLabels = commentLabelsConfig[section] {
            var selectedCommentLabelsConfiguration: [SPLabelConfiguration] = []
            for labelId in labelIds {
                if let selectedCommentLabelConfiguration = sectionLabels.getLabelById(labelId: labelId) {
                    selectedCommentLabelsConfiguration.append(selectedCommentLabelConfiguration)
                }
            }
            return selectedCommentLabelsConfiguration
        }
        
        return nil
    }
    
    // if user role exist in config translationTextOverrides -> return translation, else return user authorityTitle
    private func getUserBadgeUsingConfig(user: SPUser) -> String? {
        guard user.isStaff else { return nil }
        
        if let conversationConfig = SPConfigsDataSource.appConfig?.conversation,
           let translations = conversationConfig.translationTextOverrides,
           let currentTranslation = LocalizationManager.currentLanguage == .spanish ? translations["es-ES"] : translations[LocalizationManager.getLanguageCode()]
        {
            if user.isAdmin, let adminBadge = currentTranslation[BadgesOverrideKeys.admin.rawValue] {
                return adminBadge
            } else if user.isJournalist, let jurnalistBadge = currentTranslation[BadgesOverrideKeys.journalist.rawValue] {
                return jurnalistBadge
            } else if user.isModerator, let moderatorBadge = currentTranslation[BadgesOverrideKeys.moderator.rawValue] {
                return moderatorBadge
            } else if user.isCommunityModerator, let communityModeratorBadge = currentTranslation[BadgesOverrideKeys.communityModerator.rawValue]  {
                return communityModeratorBadge
            }
        }
        return user.authorityTitle
    }

}

enum BadgesOverrideKeys: String {
    case admin = "user.badges.admin"
    case journalist = "user.badges.jurnalist"
    case moderator = "user.badges.moderator"
    case communityModerator = "user.badges.community-moderator"
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
    static let replyActionsViewHeight: CGFloat = 32.0
    static let moreRepliesViewHeight: CGFloat = 31.0
    static let moreRepliesTopOffset: CGFloat = 12.0
}
