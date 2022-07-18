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

    weak var delegate: SPCommentCellDelegate?{
        didSet {
            userView.setDelegate(delegate)
        }
    }
    
    let messageView: MessageContainerView = .init()
    private let userView: OWCommentUserView = .init()
    private let statusIndicationView: OWCommentStatusIndicationView = .init()
    private let commentLabelView: CommentLabelView = .init()
    private let replyActionsView: OWCommentActionsView = .init()
    private let moreRepliesView: ShowMoreRepliesView = .init()
    private let commentMediaView: CommentMediaView = .init()
    private let opacityView: OWBaseView = .init()
    
    private var commentId: String?
    private var replyingToId: String?
    private var repliesButtonState: RepliesButtonState = .collapsed
    
    private var textViewLeadingConstraint: OWConstraint?
    private var commentMediaViewTopConstraint: OWConstraint?
    private var statusIndicatorViewHeighConstraint: OWConstraint?
    private var statusIndicatorViewTopConstraint: OWConstraint?
    
    private var imageRequest: DataRequest?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    func configure(with data: CommentViewModel, lineLimit: Int, isReadOnlyMode: Bool, windowWidth: CGFloat?) {
        commentId = data.commentId
        replyingToId = data.replyingToCommentId
        repliesButtonState = data.repliesButtonState
        userView.configure(with: data)
        updateActionView(with: data, isReadOnlyMode: isReadOnlyMode)
        updateCommentLabelView(with: data)
        messageView.delegate = self
        setStatusIndicatorVisibillity(isVisible: data.showStatusIndicator)
        
        textViewLeadingConstraint?.update(offset: data.depthOffset())
        let replyActionsViewHeight: CGFloat
        if data.isDeletedOrReported() {
            messageView.setMessage("",
                                   attributes: attributes(isDeleted: true),
                                   clippedTextSettings: SPClippedTextSettings(
                                    collapsed: data.commentTextCollapsed,
                                    edited: data.isEdited
                                   )
                                  )
            replyActionsViewHeight = 0.0
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
            replyActionsViewHeight = Theme.replyActionsViewHeight
        }
        replyActionsView.OWSnp.updateConstraints { make in
            make.height.equalTo(replyActionsViewHeight)
        }
        moreRepliesView.OWSnp.updateConstraints { make in
            make.height.equalTo(data.repliesButtonState == .hidden ? 0.0 : Theme.moreRepliesViewHeight)
        }
        updateRepliesButtonTitle(with: data.repliesRawCount)
        moreRepliesView.updateView(with: data.repliesButtonState)
        updateCommentMediaView(with: data)
        statusIndicationView.configure(with: data.statusIndicationVM)
    }
    
    private func setStatusIndicatorVisibillity(isVisible: Bool) {
        statusIndicationView.isHidden = !isVisible
        statusIndicatorViewHeighConstraint?.isActive = !isVisible
        statusIndicatorViewTopConstraint?.update(offset: isVisible ? Theme.statusIndicatorTopOffset :0)
        opacityView.isHidden = !isVisible
        replyActionsView.setIsDisabled(isDisabled: isVisible)
    }
    
    private func updateCommentMediaView(with dataModel: CommentViewModel) {
        guard !dataModel.isDeletedOrReported() && (dataModel.commentGifUrl != nil || dataModel.commentImage != nil) else {
            commentMediaViewTopConstraint?.update(offset: dataModel.isDeletedOrReported() ? 0.0 : SPCommonConstants.emptyCommentMediaTopPadding)
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
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        contentView.backgroundColor = .spBackground0
        opacityView.backgroundColor = .spBackground0
        messageView.updateColorsAccordingToStyle()
        userView.updateColorsAccordingToStyle()
        replyActionsView.updateColorsAccordingToStyle()
        moreRepliesView.updateColorsAccordingToStyle()
        commentLabelView.updateColorsAccordingToStyle()
        statusIndicationView.updateColorsAccordingToStyle()
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
    
    private func updateActionView(with dataModel: CommentViewModel, isReadOnlyMode: Bool) {
        replyActionsView.configure(with: dataModel.commentActionsVM, delegate: self)
        dataModel.updateCommentActionsVM()
        replyActionsView.setReadOnlyMode(enabled: isReadOnlyMode)
        replyActionsView.setReplyButton(repliesCount: dataModel.repliesCount, shouldHideButton:  dataModel.depth >= 6)
    }
    
    private func updateCommentLabelView(with dataModel: CommentViewModel) {
        let height: CGFloat
        if let commentLabels = dataModel.commentLabels,
           dataModel.isDeletedOrReported() == false,
           commentLabels.count > 0 {
            let selectedCommentLabel =  commentLabels[0]
            commentLabelView.setLabel(
                commentLabelIconUrl: selectedCommentLabel.iconUrl,
                labelColor: selectedCommentLabel.color,
                labelText: selectedCommentLabel.text,
                labelId: selectedCommentLabel.id,
                state: .readOnly)
            commentLabelView.isHidden = false
            height = Theme.commentLabelHeight
        } else {
            commentLabelView.isHidden = true
            height = 0
        }
        
        commentLabelView.OWSnp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
    
    // MARK: - Private UISetup
    
    private func setupUI() {
        contentView.addSubviews(userView, statusIndicationView, commentLabelView, messageView, replyActionsView, moreRepliesView, commentMediaView, opacityView)
        configureUserView()
        configureCommentLabelView()
        configureMessageView()
        configureReplyActionsView()
        configureMoreRepliesView()
        configureCommentMediaView()
        configureStatusIndicationView()
        configureOpacityView()
    }
    
    private func configureOpacityView() {
        opacityView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(userView.OWSnp.top)
        }
        opacityView.layer.opacity = 0.4
        opacityView.isUserInteractionEnabled = false
    }
    
    private func configureStatusIndicationView() {
        statusIndicationView.OWSnp.makeConstraints { make in
            make.leading.equalTo(messageView)
            statusIndicatorViewTopConstraint = make.top.equalToSuperview().offset(Theme.statusIndicatorTopOffset).constraint
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
            statusIndicatorViewHeighConstraint = make.height.equalTo(0).constraint
        }
    }
    
    private func configureCommentMediaView() {
        commentMediaView.OWSnp.makeConstraints { make in
            commentMediaViewTopConstraint = make.top.equalTo(messageView.OWSnp.bottom).offset(SPCommonConstants.emptyCommentMediaTopPadding).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.trailingOffset)
            make.height.width.equalTo(0)
        }
    }
    
    private func configureUserView() {
        userView.OWSnp.makeConstraints { make in
            make.top.equalTo(statusIndicationView.OWSnp.bottom).offset(Theme.topOffset)
            make.leading.equalTo(messageView)
            make.trailing.equalToSuperview()
            make.height.equalTo(Theme.userViewCollapsedHeight)
        }
    }
    
    private func configureCommentLabelView() {
        commentLabelView.OWSnp.makeConstraints { make in
            make.top.equalTo(userView.OWSnp.bottom).offset(10)
            make.leading.equalTo(messageView)
            make.height.equalTo(Theme.commentLabelHeight)
        }
    }
    
    private func configureMessageView() {
        messageView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentLabelView.OWSnp.bottom).offset(Theme.messageContainerTopOffset)
            textViewLeadingConstraint = make.leading.equalToSuperview().offset(Theme.leadingOffset).constraint
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
        }
    }
    
    private func configureReplyActionsView() {
        replyActionsView.OWSnp.makeConstraints { make in
            make.top.equalTo(commentMediaView.OWSnp.bottom)
            make.leading.equalTo(messageView)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
            make.height.equalTo(Theme.replyActionsViewHeight)
        }
    }
    
    private func configureMoreRepliesView() {
        moreRepliesView.delegate = self
        moreRepliesView.OWSnp.makeConstraints { make in
            make.top.equalTo(replyActionsView.OWSnp.bottom).offset(Theme.moreRepliesTopOffset)
            make.leading.equalTo(messageView)
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.trailingOffset)
            make.height.equalTo(Theme.moreRepliesViewHeight)
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
    static let replyActionsViewHeight: CGFloat = 32.0
    static let moreRepliesViewHeight: CGFloat = 31.0
    static let userViewCollapsedHeight: CGFloat = 44.0
    static let moreRepliesTopOffset: CGFloat = 12.0
    static let commentLabelHeight: CGFloat = 28.0
    static let statusIndicatorTopOffset: CGFloat = 16
}
