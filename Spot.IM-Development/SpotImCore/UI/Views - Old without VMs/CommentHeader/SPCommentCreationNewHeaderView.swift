//
//  SPCommentCreationHeaderView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

struct CommentReplyDataModel {
    let author: String?
    let comment: String?
}

enum HeaderMode {
    case add, edit
    var title: String {
        switch(self) {
        case .add:
            return LocalizationManager.localizedString(key: "Add a comment")
        case .edit:
            return LocalizationManager.localizedString(key: "Edit a comment")
        }
    }
}

protocol SPCommentCreationNewHeaderViewDelegate: AnyObject {
    func customizeHeaderTitle(label: UILabel)
}

final class SPCommentCreationNewHeaderView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_new_header_view_id"
        static let closeButtonIdentifier = "comment_creation_new_header_view_close_button_id"
        static let headerTitleLabelIdentifier = "comment_creation_new_header_view_header_title_label_id"
        static let replyingLabelIdentifier = "comment_creation_new_header_view_replying_label_id"
        static let commentAuthorLabelIdentifier = "comment_creation_new_header_view_comment_author_label_id"
        static let commentLabelIdentifier = "comment_creation_new_header_view_comment_label_id"
    }
    weak var delegate: SPCommentCreationNewHeaderViewDelegate?
    
    let closeButton: OWBaseButton = .init()

    private let headerTitleLabel: OWBaseLabel = .init()
    private let replyingLabel: OWBaseLabel = .init()
    private let commentAuthorLabel: OWBaseLabel = .init()
    private let commentLabel: OWBaseLabel = .init()
    private let separatorView: OWBaseView = .init()
    
    private var replyingLabelTopConstraint: OWConstraint? = nil
    private var commentLabelTopConstraint: OWConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        headerTitleLabel .accessibilityIdentifier = Metrics.headerTitleLabelIdentifier
        replyingLabel.accessibilityIdentifier = Metrics.replyingLabelIdentifier
        commentAuthorLabel.accessibilityIdentifier = Metrics.commentAuthorLabelIdentifier
        commentLabel.accessibilityIdentifier = Metrics.commentLabelIdentifier
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        headerTitleLabel.backgroundColor = .spBackground0
        headerTitleLabel.textColor = .spForeground0
        commentAuthorLabel.backgroundColor = .spBackground0
        commentAuthorLabel.textColor = .spForeground1
        closeButton.backgroundColor = .spBackground0
        commentLabel.backgroundColor = .spBackground0
        commentLabel.textColor = .spForeground1
        separatorView.backgroundColor = .spSeparator2
        closeButton.setImage(UIImage(spNamed: "closeCrossIconNew", supportDarkMode: true), for: .normal)
        
        delegate?.customizeHeaderTitle(label: headerTitleLabel)
    }
    
    func hideCommentText() {
        commentLabel.text = ""
        commentLabelTopConstraint?.update(offset: 0)
        commentLabel.isHidden = true
    }
    
    func setupHeader(for headerMode: HeaderMode) {
        headerTitleLabel.text = headerMode.title
    }
    
    // MARK: - Internal methods
    
    internal func configure(with commentModel: CommentReplyDataModel? = nil) {
        if let commentModel = commentModel {
            commentAuthorLabel.text = commentModel.author
            commentLabel.text = commentModel.comment
        } else {
            hideReplyingViews()
        }
        updateColorsAccordingToStyle()
    }
    
    // MARK: - Private Methods
    
    private func hideReplyingViews() {
        hideCommentText()
        hideReplyingLabel()
    }
    
    private func hideReplyingLabel() {
        replyingLabelTopConstraint?.update(offset: 0)
        replyingLabel.text = ""
        replyingLabel.isHidden = true
    }
    
    private func hideCommentAuthorLabel() {
        commentAuthorLabel.text = ""
        commentAuthorLabel.isHidden = true
    }
    
    private func setup() {
        addSubviews(headerTitleLabel, replyingLabel, commentAuthorLabel, closeButton, commentLabel, separatorView)
        setupHeaderTitle()
        setupReplyingLabel()
        setupCommentAuthorLabel()
        setupCloseButton()
        setupCommentLabel()
        setupSeparatorView()
        updateColorsAccordingToStyle()
    }
    
    private func setupHeaderTitle() {
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.font = UIFont.preferred(style: .bold, of: Theme.titleFontSize)
        headerTitleLabel.OWSnp.makeConstraints { make in
            make.height.equalTo(Theme.headerTitleHeight)
            make.top.equalToSuperview().offset(Theme.topOffset)
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
        }
    }
    
    private func setupCloseButton() {
        closeButton.setImage(UIImage(spNamed: "closeCrossIconNew", supportDarkMode: true), for: .normal)
        closeButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(headerTitleLabel)
            make.trailing.equalToSuperview().offset(-6.0)
            make.size.equalTo(45.0)
        }
    }
    
    private func setupSeparatorView() {
        separatorView.OWSnp.makeConstraints { make in
            make.top.equalTo(headerTitleLabel.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
        }
    }
    
    private func setupReplyingLabel() {
        replyingLabel.text = LocalizationManager.localizedString(key: "Replying to ")
        replyingLabel.font = UIFont.preferred(style: .regular, of: Theme.replyingToFontSize)
        replyingLabel.OWSnp.makeConstraints { make in
            replyingLabelTopConstraint = make.top.equalTo(separatorView.OWSnp.bottom).offset(Theme.replyingTopOffset).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
        }
    }
    
    private func setupCommentAuthorLabel() {
        commentAuthorLabel.font = UIFont.preferred(style: .bold, of: Theme.replyingToFontSize)
        commentAuthorLabel.OWSnp.makeConstraints { make in
            make.firstBaseline.lastBaseline.equalTo(replyingLabel)
            make.leading.equalTo(replyingLabel.OWSnp.trailing)
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.trailingOffset)
        }
    }
    
    private func setupCommentLabel() {
        commentLabel.numberOfLines = 2
        commentLabel.font = UIFont.preferred(style: .regular, of: Theme.commentFontSize)
        commentLabel.OWSnp.makeConstraints { make in
            commentLabelTopConstraint = make.top.equalTo(replyingLabel.OWSnp.bottom).offset(Theme.commentTopOffset).constraint
            make.leading.equalToSuperview().offset(Theme.leadingOffset)
            make.trailing.equalToSuperview().offset(-Theme.trailingOffset)
            make.bottom.equalToSuperview().offset(-Theme.commentBottomOffset)
        }
    }
}

private enum Theme {
    
    static let headerTitleHeight: CGFloat = 40.0
    static let topOffset: CGFloat = 22.0
    static let replyingTopOffset: CGFloat = 15.0
    static let commentBottomOffset: CGFloat = 10.0
    static let commentTopOffset: CGFloat = 16.0
    static let trailingOffset: CGFloat = 24.0
    static let leadingOffset: CGFloat = 15.0
    static let separatorHeight: CGFloat = 1.0
    static let titleFontSize: CGFloat = 18.0
    static let replyingToFontSize: CGFloat = 16.0
    static let commentFontSize: CGFloat = 16.0
    
}
