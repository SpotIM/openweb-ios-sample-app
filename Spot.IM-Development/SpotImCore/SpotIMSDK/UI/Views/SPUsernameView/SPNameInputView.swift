//
//  SPNameInputView.swift
//  SpotImCore
//
//  Created by Andriy Fedin on 31/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPNameInputView: BaseView, SPTextInputView {
    private lazy var avatarImageView: SPAvatarView = SPAvatarView()
    private lazy var usernameTextField: UITextField = UITextField()
    private lazy var separatorView: UIView = UIView()

    internal weak var delegate: SPTextInputViewDelegate?

    var text: String? { get { usernameTextField.text }
                        set { usernameTextField.text = newValue } }

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
        usernameTextField.becomeFirstResponder()
    }

    // MARK: - Internal methods

    private func setup() {
        addSubviews(avatarImageView, usernameTextField, separatorView)

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

        usernameTextField.textColor = .spForeground0
        usernameTextField.font = font
        usernameTextField.delegate = self

        let paceholderString = NSLocalizedString(
            "Your nickname",
            comment: "Nickname placeholder for unregistered users"
        )

        let placeholder = NSAttributedString(
            string: paceholderString,
            attributes: [.foregroundColor: UIColor.spForeground2, .font: font]
        )
        usernameTextField.attributedPlaceholder = placeholder
        usernameTextField.layout {
            $0.leading.equal(to: avatarImageView.trailingAnchor, offsetBy: Theme.usernameLeading)
            $0.centerY.equal(to: avatarImageView.centerYAnchor)
            $0.trailing.equal(to: trailingAnchor, offsetBy: Theme.xOffset)
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
            object: usernameTextField
        )
    }

    @objc
    private func textFieldDidChange() {
        notifyDelegateAboutChange()
    }

    private func notifyDelegateAboutChange() {
        delegate?.input(self, didChange: usernameTextField.text ?? "")
    }
}

// MARK: - Extensions

extension SPNameInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        notifyDelegateAboutChange()
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
