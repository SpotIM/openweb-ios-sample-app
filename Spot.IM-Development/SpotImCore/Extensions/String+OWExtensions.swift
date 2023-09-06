//
//  String+OWExtensions.swift
//  SpotImCore
//
//  Created by Refael Sommer on 03/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

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
}
