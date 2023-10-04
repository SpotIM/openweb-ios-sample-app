//
//  String+OWExtensions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

extension String {
    var locateURLInText: URL? {
        let linkType: NSTextCheckingResult.CheckingType = [.link]

        var url: URL? = nil
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let matches = detector.matches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: self.count)
            )

            for match in matches {
                if let urlMatch = match.url {
                    url = urlMatch
                }
            }
        }

        return url
    }

    var attributedString: NSMutableAttributedString {
        return NSMutableAttributedString(string: self)
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
            let from = from16.samePosition(in: self),
            let to = to16.samePosition(in: self)
        else { return nil }
        return from ..< to
    }

    func getAttributedText(textColor: UIColor,
                           textFont: UIFont,
                           linkedText: String?,
                           linkURL: URL?,
                           linkColor: UIColor,
                           linkFont: UIFont,
                           paragraphAlignment: NSTextAlignment) -> NSMutableAttributedString {

        let attributedString = NSMutableAttributedString(string: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = paragraphAlignment

        // Set default attributes for the entire string
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: textFont,
            .foregroundColor: textColor
        ]
        attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: self.count))

        // Search for the linkedText in the main text
        if let _ = linkURL,
            let link = linkedText,
            let range = self.range(of: link) {

            let nsRange = NSRange(range, in: self)

            // Set link attributes on the linkedText
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: 1,
                .font: linkFont,
                .foregroundColor: linkColor
            ]
            attributedString.addAttributes(linkAttributes, range: nsRange)
        }

        return attributedString
    }
}
