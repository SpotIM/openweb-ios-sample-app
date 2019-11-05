//
//  SPCommentHeaderView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/5/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

struct CommentDataModel {
    let author: String?
    let comment: String?
}

final class SPCommentHeaderView: BaseView {
    
    let closeButton: UIButton = .init()

    private let replyingLabel: UILabel = .init()
    private let commentAuthorLabel: UILabel = .init()
    private let commentLabel: UILabel = .init()
    private let separatorView: UIView = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // MARK: - Internal methods
    
    internal func configure(with commentModel: CommentDataModel) {
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
    }
    
    private func setupReplyingLabel() {
        replyingLabel.text = LocalizationManager.localizedString(key: "Replying to ")
        replyingLabel.backgroundColor = .spBackground0
        replyingLabel.textColor = .spForeground4
        replyingLabel.font = UIFont.roboto(style: .regular, of: Theme.titleFontSize)
        replyingLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.topOffset)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.leadingOffset)
        }
    }
    
    private func setupCommentAuthorLabel() {
        commentAuthorLabel.backgroundColor = .spBackground0
        commentAuthorLabel.textColor = .spForeground1
        commentAuthorLabel.font = UIFont.roboto(style: .bold, of: Theme.titleFontSize)
        
        commentAuthorLabel.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.topOffset)
            $0.leading.equal(to: replyingLabel.trailingAnchor)
            $0.trailing.lessThanOrEqual(to: closeButton.leadingAnchor, offsetBy: -Theme.trailingOffset)
        }
    }
    
    private func setupCloseButton() {
        closeButton.setImage(UIImage(spNamed: "closeCrossIcon"), for: .normal)
        closeButton.backgroundColor = .spBackground0
        closeButton.layout {
            $0.centerY.equal(to: commentAuthorLabel.centerYAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -5.0)
            $0.width.equal(to: 40.0)
            $0.height.equal(to: 40.0)
        }
    }
    
    private func setupCommentLabel() {
        commentLabel.backgroundColor = .spBackground0
        commentLabel.numberOfLines = 3
        commentLabel.textColor = .spForeground1
        commentLabel.font = UIFont.roboto(style: .regular, of: Theme.commentFontSize)
        
        commentLabel.layout {
            $0.top.equal(to: replyingLabel.bottomAnchor, offsetBy: Theme.commentTopOffset)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.leadingOffset)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.trailingOffset)
            $0.bottom.equal(to: separatorView.topAnchor, offsetBy: -Theme.commentBottomOffset)
        }
    }
    
    private func setupSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }
}

private enum Theme {
    
    static let topOffset: CGFloat = 26.0
    static let commentTopOffset: CGFloat = 22.0
    static let commentBottomOffset: CGFloat = 24.0
    static let trailingOffset: CGFloat = 24.0
    static let leadingOffset: CGFloat = 25.0
    static let separatorHeight: CGFloat = 1.0
    static let titleFontSize: CGFloat = 16.0
    static let commentFontSize: CGFloat = 16.0
    
}
