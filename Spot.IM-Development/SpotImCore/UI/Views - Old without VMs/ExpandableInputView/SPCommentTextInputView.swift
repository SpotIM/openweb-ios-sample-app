//
//  SPTextInputView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPTextInputView: AnyObject {

    var text: String? { get set }

}

internal protocol SPTextInputViewDelegate: AnyObject {

    func input(_ view: SPTextInputView, didChange text: String)
    func validateInput(lenght: Int) -> Bool
}

final class SPCommentTextInputView: SPBaseView, SPTextInputView {
    fileprivate struct Metrics {
        static let identifier = "comment_text_input_view_id"
        static let textInputViewIdentifier = "comment_text_input_view_text_input_view_id"
    }
    enum CommentType {
        case comment, reply
    }

    weak var delegate: SPTextInputViewDelegate?

    var text: String? { get { textInputView.text }
                        set { textInputView.text = newValue } }

    private let textInputView: SPInputTextView = SPInputTextView()
    private lazy var avatarUserView: SPAvatarView = SPAvatarView()

    private var textToAvatarConstraint: OWConstraint?
    private var textToLeadingConstraint: OWConstraint?
    // MARK: - Init

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupUI()
        applyAccessibility()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        textInputView.accessibilityIdentifier = Metrics.textInputViewIdentifier
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        textInputView.backgroundColor = .spBackground0
        textInputView.textColor = .spForeground1
        textInputView.autocorrectionType = !UIDevice.current.isPortrait() || UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? .no : .yes
        avatarUserView.updateColorsAccordingToStyle()
    }

    func setKeyboardAccordingToDeviceOrientation(isPortrait: Bool) {
        textInputView.setKeyboardAccordingToDeviceOrientation(isPortrait: isPortrait)
    }

    func makeFirstResponder() {
        textInputView.becomeFirstResponder()
    }

    func updateText(_ text: String) {
        textInputView.text = text
        delegate?.input(self, didChange: text)
    }

    func configureCommentType(_ type: CommentType, avatar: URL? = nil, showAvatar: Bool = false) {
        switch type {
        case .comment:
            textInputView.placeholder = SPLocalizationManager.localizedString(key: "WhatDoYouThink")

        case .reply:
            textInputView.placeholder = SPLocalizationManager.localizedString(key: "Type your reply…")
        }

        setShowAvatar(showAvatar: showAvatar)
    }

    func configureAvatarViewModel(with model: SPAvatarViewModeling) {
        self.avatarUserView.configure(with: model)
    }

    func setShowAvatar(showAvatar: Bool) {
        if showAvatar {
            avatarUserView.isHidden = false
            textToLeadingConstraint?.deactivate()
            textToAvatarConstraint?.activate()
        } else {
            avatarUserView.isHidden = true
            textToAvatarConstraint?.deactivate()
            textToLeadingConstraint?.activate()
        }
    }

    private func setupUI() {
        addSubviews(textInputView, avatarUserView)
        configureAvatarView()
        configureTextInputView()
        updateColorsAccordingToStyle()
    }

    private func configureAvatarView() {
        avatarUserView.isHidden = true
        avatarUserView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(Theme.avatarImageViewLeading)
            make.size.equalTo(Theme.avatarImageViewSize)
        }
    }

    private func configureTextInputView() {
        textInputView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Theme.textInputViewTopOffset)
            make.bottom.trailing.equalToSuperview()
            textToLeadingConstraint = make.leading.equalToSuperview().constraint
            textToAvatarConstraint = make.leading.equalTo(avatarUserView.OWSnp.trailing).offset(Theme.commentLeadingOffset).constraint
        }
        textToLeadingConstraint?.deactivate()
        textToAvatarConstraint?.deactivate()

        textInputView.delegate = self
        textInputView.font = UIFont.spPreferred(style: .regular, of: Theme.commentTextFontSize)
        textInputView.textAlignment = SPLocalizationManager.getTextAlignment()
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

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)

        return delegate?.validateInput(lenght: newText.count) ?? true
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
