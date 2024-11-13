//
//  NSMutableAttributedString+OWExtensions.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import Foundation

extension NSMutableAttributedString {
    @discardableResult func font(_ font: UIFont, forText text: String? = nil) -> NSMutableAttributedString {
        let text = text ?? self.string
        if let range = self.string.range(of: text) {
            let nsRange = NSRange(range, in: self.string)
            self.addAttribute(NSAttributedString.Key.font, value: font, range: nsRange)
        }
        return self
    }

    @discardableResult func color(_ color: UIColor, forText text: String? = nil) -> NSMutableAttributedString {
        let text = text ?? self.string
        if let range = self.string.range(of: text) {
            let nsRange = NSRange(range, in: self.string)
            self.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: color,
                              range: nsRange)
        }
        return self
    }

    @discardableResult func underline(_ style: Int, forText text: String? = nil) -> NSMutableAttributedString {
        let text = text ?? self.string
        if let range = self.string.range(of: text) {
            let nsRange = NSRange(range, in: self.string)
            self.addAttribute(.underlineStyle, value: style, range: nsRange)
        }
        return self
    }

    /// Removes attachemnt placeholder char that the OS adds after dismissing dictation.
    func removeAttachmentChar() {
        guard let attachmentChar = String(unicodeCodePoint: NSTextAttachment.character) else { return }
        let attachmentCharRange = mutableString.range(of: attachmentChar)
        guard attachmentCharRange.location != NSNotFound else { return }
        replaceCharacters(in: attachmentCharRange, with: "")
    }
}
