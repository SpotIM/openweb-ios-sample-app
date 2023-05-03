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
}
