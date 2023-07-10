//
//  InputTextView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPInputTextView: SPBaseTextView {

    deinit {
        removeObservers()
    }

    override public var text: String! {
        didSet {
            textDidChange()
        }
    }

    override public var bounds: CGRect {
        didSet {
            resizePlaceholder()
        }
    }

    var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = placeholderLabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            guard let palceholder = newValue else { return }
            if let placeholderLabel = placeholderLabel {
                placeholderLabel.text = palceholder
                placeholderLabel.sizeToFit()
            } else {
                addObservers()
                addPlaceholder(palceholder)
            }
        }
    }

    private var placeholderLabel: SPBaseLabel?

    private func resizePlaceholder() {
        if let placeholderLabel = placeholderLabel {
            let labelX = textContainer.lineFragmentPadding
            let labelY = textContainerInset.top - 2
            let labelWidth = frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        placeholderLabel = SPBaseLabel()
        guard let placeholderLabel = placeholderLabel else { return }
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.font = font
        placeholderLabel.textColor = .coolGrey
        placeholderLabel.isHidden = !text.isEmpty

        addSubview(placeholderLabel)
        resizePlaceholder()
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )

    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func textDidChange() {
        placeholderLabel?.isHidden = !text.isEmpty
    }

    func setKeyboardAccordingToDeviceOrientation(isPortrait: Bool) {
        // set keyboard suggestions
        self.autocorrectionType = isPortrait && !(UIDevice.current.screenType == .iPhones_5_5s_5c_SE) ? .yes : .no
        // set done button
        if (isPortrait) {
            self.removeDoneButtonOnKeyboard()
        } else {
            self.addDoneButtonOnKeyboard()
        }
        // close & reopen keyboard to view changes
        if self.isFirstResponder {
            self.resignFirstResponder()
            self.becomeFirstResponder()
        }
    }

}
