//
//  SPCommentReplyHeaderView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/5/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPCommentReplyHeaderView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "comment_reply_header_view_id"
        static let closeButtonIdentifier = "comment_reply_header_view_close_button_id"
        static let replyingLabelIdentifier = "comment_reply_header_view_reply_label_id"
        static let commentAuthorLabelIdentifier = "comment_reply_header_view_comment_author_label_id"
        static let commentLabelIdentifier = "comment_reply_header_view_comment_label_id"
    }
    let closeButton: OWBaseButton = .init()

    private let replyingLabel: OWBaseLabel = .init()
    private let commentAuthorLabel: OWBaseLabel = .init()
    private let commentLabel: OWBaseLabel = .init()
    private let separatorView: OWBaseView = .init()
    
    private var commentLabelTopConstraint: OWConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        replyingLabel.accessibilityIdentifier = Metrics.replyingLabelIdentifier
        commentAuthorLabel.accessibilityIdentifier = Metrics.commentAuthorLabelIdentifier
        commentLabel.accessibilityIdentifier = Metrics.commentLabelIdentifier
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        replyingLabel.backgroundColor = .spBackground0
        replyingLabel.textColor = .spForeground4
        commentAuthorLabel.backgroundColor = .spBackground0
        commentAuthorLabel.textColor = .spForeground1
        closeButton.backgroundColor = .spBackground0
        commentLabel.backgroundColor = .spBackground0
        commentLabel.textColor = .spForeground1
        separatorView.backgroundColor = .spSeparator2
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
    }
    
    func hideCommentText() {
        commentLabel.text = ""
        commentLabelTopConstraint?.update(offset: 0)
        commentLabel.isHidden = true
    }
    
    // MARK: - Internal methods
    
    internal func configure(with commentModel: CommentReplyDataModel) {
        commentAuthorLabel.text = commentModel.author
        commentLabel.text = commentModel.comment
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        addSubviews(replyingLabel, commentAuthorLabel, closeButton, commentLabel, separatorView)
        setupReplyingLabel()
        setupCommentAuthorLabel()
        setupCloseButton()
        setupCommentLabel()
        setupSeparatorView()
        updateColorsAccordingToStyle()
    }
    
    private func setupReplyingLabel() {
        replyingLabel.text = LocalizationManager.localizedString(key: "Replying to ")
        replyingLabel.font = UIFont.preferred(style: .regular, of: Theme.titleFontSize)
        replyingLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.topOffset)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
        }
    }
    
    private func setupCommentAuthorLabel() {
        commentAuthorLabel.font = UIFont.preferred(style: .bold, of: Theme.titleFontSize)
        commentAuthorLabel.OWSnp.makeConstraints { make in
            make.firstBaseline.equalTo(replyingLabel)
            make.lastBaseline.equalTo(replyingLabel)
            make.leading.equalTo(replyingLabel.OWSnp.trailing)
            make.trailing.lessThanOrEqualTo(closeButton.OWSnp.leading).offset(-Theme.trailingOffset)
        }
    }
    
    private func setupCloseButton() {
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(commentAuthorLabel)
            make.trailing.equalToSuperview().offset(-Theme.closeButtonTrailingOffset)
            make.size.equalTo(Theme.closeButtonSize)
        }
    }
    
    private func setupCommentLabel() {
        commentLabel.numberOfLines = 3
        commentLabel.font = UIFont.preferred(style: .regular, of: Theme.commentFontSize)
        commentLabel.OWSnp.makeConstraints { make in
            commentLabelTopConstraint = make.top.equalTo(replyingLabel.OWSnp.bottom).offset(Theme.commentTopOffset).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
            make.bottom.equalTo(separatorView.OWSnp.top).offset(-Theme.commentBottomOffset)
        }
    }
    
    private func setupSeparatorView() {
        separatorView.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
        }
    }
}

private enum Theme {
    
    static let topOffset: CGFloat = 26.0
    static let commentTopOffset: CGFloat = 22.0
    static let commentBottomOffset: CGFloat = 24.0
    static let trailingOffset: CGFloat = 24.0
    static let leadingOffset: CGFloat = 15.0
    static let separatorHeight: CGFloat = 1.0
    static let titleFontSize: CGFloat = 16.0
    static let commentFontSize: CGFloat = 16.0
    static let closeButtonSize: CGFloat = 40.0
    static let closeButtonTrailingOffset: CGFloat = 6.0
    
}
