//
//  SPTextInputView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

protocol SPTextInputViewDelegate: class {
    
    func textDidChange(_ text: String)
    func tooLongTextWasPassed()
    
}

final class SPTextInputView: BaseView {

    enum CommentType {
        case comment, reply
    }
    
    weak var delegate: SPTextInputViewDelegate?
    private let textInputView: InputTextView = InputTextView()
    private let avatarImageView: SPAvatarView = SPAvatarView()
    
    private var commentLeadingConstraint: NSLayoutConstraint?
    private var replyLeadingConstraint: NSLayoutConstraint?

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    func makeFirstResponder() {
        textInputView.becomeFirstResponder()
    }
    
    func updateAvatar(_ image: UIImage?) {
        avatarImageView.updateAvatar(image: image)
    }
    
    func updateText(_ text: String) {
        textInputView.text = text
        delegate?.textDidChange(text)
    }
    
    func configureCommentType(_ commentType: CommentType, avatar: URL? = nil) {
        avatarImageView.updateAvatar(avatarUrl: avatar)
        avatarImageView.updateOnlineStatus(.online)
        avatarImageView.isHidden = false
        commentLeadingConstraint?.isActive = true
        switch commentType {
        case .comment:
            textInputView.placeholder = NSLocalizedString(
                "What do you think?",
                bundle: Bundle.spot,
                comment: "text view comment placeholder"
            )
            
        case .reply:
            textInputView.placeholder = NSLocalizedString(
                "Type your reply…",
                bundle: Bundle.spot, comment: "text view reply placeholder"
            )
        }
    }
    
    private func setupUI() {
        addSubviews(textInputView, avatarImageView)
        configureAvatarView()
        configureTextInputView()
    }
    
    private func configureAvatarView() {
        avatarImageView.isHidden = true
        avatarImageView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.height.equal(to: Theme.avatarImageViewSize)
            $0.width.equal(to: Theme.avatarImageViewSize)
        }
    }
    
    private func configureTextInputView() {
        textInputView.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.textInputViewTopOffset)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            replyLeadingConstraint = $0.leading.equal(to: leadingAnchor, isActive: false)
            commentLeadingConstraint = $0.leading.equal(to: avatarImageView.trailingAnchor,
                                                        offsetBy: Theme.commentLeadingOffset,
                                                        isActive: false)
        }
        textInputView.delegate = self
        textInputView.tintColor = .brandColor
        textInputView.backgroundColor = .spBackground0
        textInputView.font = UIFont.roboto(style: .regular, of: Theme.commentTextFontSize)
        textInputView.textColor = .spForeground1
        textInputView.textAlignment = .natural
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft {
            textInputView.textAlignment = .right
        } else {
            textInputView.textAlignment = .left
        }
    }
}

extension SPTextInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.textDidChange(textView.text)
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
        ) -> Bool {
        let shouldReplace = true
        
//        if let currentText = textView.text,
//            let textRange = Range(range, in: currentText) {
//            let possibleText = currentText
//                .replacingCharacters(in: textRange, with: text)
//                .trimmingCharacters(in: .whitespacesAndNewlines)
//            shouldReplace = possibleText.count <= Theme.maximumCommentLength
//
//            if possibleText.count - Theme.maximumCommentLength > 1 {
//                delegate?.tooLongTextWasPassed()
//            }
//        }
        
        return shouldReplace
    }
}

private enum Theme {
    
    static let commentTextFontSize: CGFloat = 16.0
    static let commentLeadingOffset: CGFloat = 11.0
    static let avatarImageViewSize: CGFloat = 39.0
    static let textInputViewTopOffset: CGFloat = 4.0
    static let maximumCommentLength: Int = 1000
}
