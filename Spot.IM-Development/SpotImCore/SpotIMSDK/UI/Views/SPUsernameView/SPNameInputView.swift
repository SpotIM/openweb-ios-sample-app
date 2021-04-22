//
//  SPNameInputView.swift
//  SpotImCore
//
//  Created by Andriy Fedin on 31/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPNameInputView: BaseView, SPTextInputView {
    private lazy var avatarImageView: SPAvatarView = .init()
    private lazy var usernameTextView: InputTextView = .init()
    private lazy var separatorView: UIView = .init()

    internal weak var delegate: SPTextInputViewDelegate?

    var text: String? { get { usernameTextView.text }
                        set { usernameTextView.text = newValue } }

    // MARK: - Overrides

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func updateAvatar(_ image: UIImage?) {
        avatarImageView.updateAvatar(image: image)
    }

    func updateAvatar(_ url: URL?) {
        avatarImageView.updateAvatar(avatarUrl: url)
    }

    func makeFirstResponder() {
        usernameTextView.becomeFirstResponder()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .clear
        usernameTextView.textColor = .spForeground0
        usernameTextView.backgroundColor = .spBackground0
        usernameTextView.autocorrectionType = UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? .no : .yes
        separatorView.backgroundColor = .spSeparator2
        avatarImageView.updateColorsAccordingToStyle()
    }

    // MARK: - Internal methods

    private func setup() {
        addSubviews(avatarImageView, usernameTextView, separatorView)

        setupAvatarImageView()
        setupUsernameTextField()
        setupSeparatorView()
        subscribeToTextFieldChange()
    }

    private func setupAvatarImageView() {
        avatarImageView.layout {
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.xOffset)
            $0.top.greaterThanOrEqual(to: topAnchor)
            $0.bottom.lessThanOrEqual(to: bottomAnchor)
            $0.centerY.equal(to: centerYAnchor)
            $0.height.equal(to: Theme.avatarSideSize)
            $0.width.equal(to: Theme.avatarSideSize)
        }
    }

    private func setupUsernameTextField() {
        let font = UIFont.preferred(style: .regular, of: Theme.fontSize)

        usernameTextView.textColor = .spForeground0
        usernameTextView.textAlignment = LocalizationManager.getTextAlignment()
        usernameTextView.backgroundColor = .spBackground0
        usernameTextView.font = font
        usernameTextView.delegate = self
        usernameTextView.textContainer.maximumNumberOfLines = 1
        
        usernameTextView.placeholder = LocalizationManager.localizedString(key: "Your nickname")
        usernameTextView.layout {
            $0.leading.equal(to: avatarImageView.trailingAnchor, offsetBy: Theme.usernameLeading)
            $0.centerY.equal(to: avatarImageView.centerYAnchor, offsetBy: usernameTextView.textContainer.lineFragmentPadding)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -Theme.xOffset)
            $0.height.equal(to: avatarImageView.heightAnchor)
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

    private func subscribeToTextFieldChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidChange),
            name: UITextField.textDidChangeNotification,
            object: usernameTextView
        )
    }

    @objc
    private func textFieldDidChange() {
        notifyDelegateAboutChange()
    }

    private func notifyDelegateAboutChange() {
        delegate?.input(self, didChange: usernameTextView.text ?? "")
    }
}

// MARK: - Extensions

extension SPNameInputView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        notifyDelegateAboutChange()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        notifyDelegateAboutChange()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return text.rangeOfCharacter(from: .newlines) == nil && (textView.text.length + text.length) <= 12
    }
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let xOffset: CGFloat = 14.0
    static let separatorHeight: CGFloat = 1.0
    static let usernameLeading: CGFloat = 10.0
    static let avatarSideSize: CGFloat = 44.0
}
