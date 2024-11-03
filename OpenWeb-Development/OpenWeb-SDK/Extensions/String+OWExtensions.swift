//
//  String+OWExtensions.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

extension String {
    var locateURLInText: URL? {
        let linkType: NSTextCheckingResult.CheckingType = [.link]

        var url: URL?
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let matches = detector.matches(
                in: self,
                options: [],
                range: NSRange(self.startIndex..., in: self)
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
        attributedString.addAttributes(defaultAttributes, range: NSRange(self.startIndex..., in: self))

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
