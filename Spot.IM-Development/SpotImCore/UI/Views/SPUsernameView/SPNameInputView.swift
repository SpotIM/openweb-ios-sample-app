//
//  SPNameInputView.swift
//  SpotImCore
//
//  Created by Andriy Fedin on 31/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class SPNameInputView: OWBaseView, SPTextInputView {
    private (set) lazy var avatarImageView: SPAvatarView = .init()
    private lazy var usernameTextView: OWInputTextView = .init()
    private lazy var separatorView: UIView = .init()

    internal weak var delegate: SPTextInputViewDelegate?

    var text: String? { get { usernameTextView.text }
                        set { usernameTextView.text = newValue } }

    var isSelected: Bool {
        usernameTextView.isFirstResponder
    }
    
    let font = UIFont.preferred(style: .regular, of: Theme.fontSize)
    let boldFont = UIFont.preferred(style: .bold, of: Theme.fontSize)
    
    // MARK: - Overrides

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    func makeFirstResponder() {
        usernameTextView.becomeFirstResponder()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .clear
        usernameTextView.textColor = .spForeground0
        usernameTextView.backgroundColor = .spBackground0
        usernameTextView.autocorrectionType = !UIDevice.current.isPortrait() || UIDevice.current.screenType == .iPhones_5_5s_5c_SE ? .no : .yes
        separatorView.backgroundColor = .spSeparator2
        avatarImageView.updateColorsAccordingToStyle()
    }
    
    func setKeyboardAccordingToDeviceOrientation(isPortrait: Bool) {
        usernameTextView.setKeyboardAccordingToDeviceOrientation(isPortrait: isPortrait)
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
        avatarImageView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.xOffset)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(Theme.avatarSideSize)
        }
    }

    private func setupUsernameTextField() {
        usernameTextView.textColor = .spForeground1
        usernameTextView.textAlignment = LocalizationManager.getTextAlignment()
        usernameTextView.backgroundColor = .spBackground0
        usernameTextView.font = usernameTextView.isEditable ? font : boldFont
        usernameTextView.delegate = self
        usernameTextView.textContainer.maximumNumberOfLines = 1
        
        usernameTextView.placeholder = LocalizationManager.localizedString(key: "Your Username")
        usernameTextView.OWSnp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.OWSnp.trailing).offset(Theme.usernameLeading)
            make.centerY.equalTo(avatarImageView).offset(usernameTextView.textContainer.lineFragmentPadding)
            make.trailing.equalToSuperview().offset(-Theme.xOffset)
            make.height.equalTo(avatarImageView)
        }
    }
    
    func setTextAccess(isEditable: Bool) {
        usernameTextView.isEditable = isEditable
        usernameTextView.isSelectable = isEditable
        usernameTextView.font = isEditable ? font : boldFont
    }

    private func setupSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Theme.separatorVerticalPadding)
            make.trailing.equalToSuperview().offset(-Theme.separatorVerticalPadding)
            make.bottom.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)

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
    static let fontSize: CGFloat = 14.0
    static let xOffset: CGFloat = 14.0
    static let separatorHeight: CGFloat = 1.0
    static let usernameLeading: CGFloat = 10.0
    static let avatarSideSize: CGFloat = 44.0
    static let separatorVerticalPadding: CGFloat = 15.0
}
