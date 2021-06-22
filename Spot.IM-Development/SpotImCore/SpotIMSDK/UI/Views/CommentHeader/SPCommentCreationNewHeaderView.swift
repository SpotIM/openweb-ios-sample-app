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

protocol SPCommentCreationNewHeaderViewDelegate: AnyObject {
    func customizeHeaderTitle(textView: UITextView)
}

final class SPCommentCreationNewHeaderView: BaseView {
    
    weak var delegate: SPCommentCreationNewHeaderViewDelegate?
    
    let closeButton: BaseButton = .init()

    private let headerTitleLabel: BaseTextView = .init()
    private let replyingLabel: BaseLabel = .init()
    private let commentAuthorLabel: BaseLabel = .init()
    private let commentLabel: BaseLabel = .init()
    private let separatorView: BaseView = .init()
    
    private var replyingLabelTopConstraint: NSLayoutConstraint? = nil
    private var commentLabelTopConstraint: NSLayoutConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
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
        closeButton.setImage(UIImage(spNamed: "closeCrossIconNew"), for: .normal)
        
        delegate?.customizeHeaderTitle(textView: headerTitleLabel)
    }
    
    func hideCommentText() {
        commentLabel.text = ""
        commentLabelTopConstraint?.constant = 0
        commentLabel.isHidden = true
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
        replyingLabelTopConstraint?.constant = 0
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
        headerTitleLabel.text = LocalizationManager.localizedString(key: "Add a Comment")
        headerTitleLabel.textAlignment = .center
        headerTitleLabel.font = UIFont.preferred(style: .bold, of: Theme.titleFontSize)
        headerTitleLabel.layout {
            $0.height.equal(to: Theme.headerTitleHeight)
            $0.top.equal(to: topAnchor, offsetBy: Theme.topOffset)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func setupCloseButton() {
        closeButton.setImage(UIImage(spNamed: "closeCrossIconNew"), for: .normal)
        closeButton.layout {
            $0.centerY.equal(to: headerTitleLabel.centerYAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -6.0)
            $0.width.equal(to: 45.0)
            $0.height.equal(to: 45.0)
        }
    }
    
    private func setupSeparatorView() {
        separatorView.layout {
            $0.top.equal(to: headerTitleLabel.bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }
    
    private func setupReplyingLabel() {
        replyingLabel.text = LocalizationManager.localizedString(key: "Replying to ")
        replyingLabel.font = UIFont.preferred(style: .regular, of: Theme.replyingToFontSize)
        replyingLabel.layout {
            replyingLabelTopConstraint = $0.top.equal(to: separatorView.bottomAnchor, offsetBy: Theme.replyingTopOffset)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.leadingOffset)
        }
    }
    
    private func setupCommentAuthorLabel() {
        commentAuthorLabel.font = UIFont.preferred(style: .bold, of: Theme.replyingToFontSize)
        commentAuthorLabel.layout {
            $0.firstBaseline.equal(to: replyingLabel.firstBaselineAnchor)
            $0.lastBaseline.equal(to: replyingLabel.lastBaselineAnchor)
            $0.leading.equal(to: replyingLabel.trailingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func setupCommentLabel() {
        commentLabel.numberOfLines = 3
        commentLabel.font = UIFont.preferred(style: .regular, of: Theme.commentFontSize)
        
        commentLabel.layout {
            commentLabelTopConstraint = $0.top.equal(to: replyingLabel.bottomAnchor, offsetBy: Theme.commentTopOffset)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.trailingOffset)
            $0.bottom.greaterThanOrEqual(to: bottomAnchor)
        }
    }
}

private enum Theme {
    
    static let headerTitleHeight: CGFloat = 40.0
    static let topOffset: CGFloat = 22.0
    static let replyingTopOffset: CGFloat = 15.0
    static let commentTopOffset: CGFloat = 16.0
    static let trailingOffset: CGFloat = 24.0
    static let leadingOffset: CGFloat = 15.0
    static let separatorHeight: CGFloat = 1.0
    static let titleFontSize: CGFloat = 18.0
    static let replyingToFontSize: CGFloat = 16.0
    static let commentFontSize: CGFloat = 16.0
    
}
