//
//  NSMutableAttributedString+OWExtensions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import Foundation

extension NSMutableAttributedString {
    @discardableResult func fontForText(_ font: UIFont, text: String? = nil) -> NSMutableAttributedString {
        let text = text ?? self.string
        if let range = self.string.range(of: text) {
            let nsRange = NSRange(range, in: self.string)
            self.addAttribute(NSAttributedString.Key.font, value: font, range: nsRange)
        }
        return self
    }

    @discardableResult func colorForText(_ color: UIColor, text: String? = nil) -> NSMutableAttributedString {
        let text = text ?? self.string
        if let range = self.string.range(of: text) {
            let nsRange = NSRange(range, in: self.string)
            self.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: color,
                                        range: nsRange)
        }
        return self
    }
}
