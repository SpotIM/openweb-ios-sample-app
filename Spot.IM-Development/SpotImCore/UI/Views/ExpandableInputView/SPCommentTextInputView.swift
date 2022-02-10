//
//  SPTextInputView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPTextInputView: AnyObject {

    var text: String? { set get }

}

internal protocol SPTextInputViewDelegate: AnyObject {
    
    func input(_ view: SPTextInputView, didChange text: String)
    func tooLongTextWasPassed()
    
}

final class SPCommentTextInputView: OWBaseView, SPTextInputView {

    enum CommentType {
        case comment, reply
    }
    
    weak var delegate: SPTextInputViewDelegate?

    var text: String? { get { textInputView.text }
                        set { textInputView.text = newValue } }

    private let textInputView: OWInputTextView = OWInputTextView()
    private lazy var avatarImageView: SPAvatarView = SPAvatarView()
    
    private var textToAvatarConstraint: NSLayoutConstraint?
    private var textToLeadingConstraint: NSLayoutConstraint?
    private var showingAvatar: Bool = false

    // MARK: - Init
    
    init(frame: CGRect = .zero, hasAvatar: Bool) {
        super.init(frame: frame)
        showingAvatar = hasAvatar
        setupUI()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        textInputView.backgroundColor = .spBackground0
        textInputView.textColor = .spForeground1
        textInputView.autocorrectionType = !UIDevice.current.isPortrait() || UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? .no : .yes
        avatarImageView.updateColorsAccordingToStyle()
    }
    
    func setKeyboardAccordingToDeviceOrientation(isPortrait: Bool) {
        textInputView.setKeyboardAccordingToDeviceOrientation(isPortrait: isPortrait)
    }

    func makeFirstResponder() {
        textInputView.becomeFirstResponder()
    }
    
    func updateAvatar(_ image: UIImage?) {
        avatarImageView.updateAvatar(image: image)
    }
    
    func updateText(_ text: String) {
        textInputView.text = text
        delegate?.input(self, didChange: text)
    }

    func configureCommentType(_ type: CommentType, avatar: URL? = nil) {
        
        switch type {
        case .comment:
            textInputView.placeholder = LocalizationManager.localizedString(key: "What do you think?")
            
        case .reply:
            textInputView.placeholder = LocalizationManager.localizedString(key: "Type your reply…")
        }

        if showingAvatar {
            avatarImageView.updateAvatar(avatarUrl: avatar)
            avatarImageView.updateOnlineStatus(.online)
            avatarImageView.isHidden = false
            textToLeadingConstraint?.isActive = false
            textToAvatarConstraint?.isActive = true
        } else {
            avatarImageView.isHidden = true
            textToAvatarConstraint?.isActive = false
            textToLeadingConstraint?.isActive = true
        }
    }
    
    private func setupUI() {
        addSubviews(textInputView, avatarImageView)
        configureAvatarView()
        configureTextInputView()
        updateColorsAccordingToStyle()
    }
    
    private func configureAvatarView() {
        avatarImageView.isHidden = true
        avatarImageView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.avatarImageViewLeading)
            $0.height.equal(to: Theme.avatarImageViewSize)
            $0.width.equal(to: Theme.avatarImageViewSize)
        }
    }
    
    private func configureTextInputView() {
        textInputView.layout {
            $0.top.equal(to: topAnchor, offsetBy: Theme.textInputViewTopOffset)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
            textToLeadingConstraint = $0.leading.equal(to: leadingAnchor, isActive: false)
            textToAvatarConstraint = $0.leading.equal(to: avatarImageView.trailingAnchor,
                                                      offsetBy: Theme.commentLeadingOffset,
                                                      isActive: false)
        }
        textInputView.delegate = self
        textInputView.font = UIFont.preferred(style: .regular, of: Theme.commentTextFontSize)
        textInputView.textAlignment = LocalizationManager.getTextAlignment()
        textInputView.isScrollEnabled = false
    }
    
    private func getParentScrollViewOfTextInputView() -> UIScrollView? {
        let parentView = textInputView.superview!
        if let scrollView = parentView.superview as? UIScrollView {
            return scrollView
        } else {
            return nil
        }
    }
    
    private func ensureCursorVisibleOnBottom(textView: UITextView) {
        guard let scrollView = getParentScrollViewOfTextInputView(),
              let range = textView.selectedTextRange,
              textView.offset(from: textView.beginningOfDocument, to: range.start) == textView.text.count,
              scrollView.bounds.size.height < (textView.bounds.size.height + 25)
        else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: (textInputView.bounds.size.height + 50) - scrollView.bounds.size.height), animated: true)
    }
}

extension SPCommentTextInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.input(self, didChange: textView.text)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        ensureCursorVisibleOnBottom(textView: textView)
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
    static let avatarImageViewLeading: CGFloat = 6.0
    static let textInputViewTopOffset: CGFloat = 4.0
    static let maximumCommentLength: Int = 1000
}
