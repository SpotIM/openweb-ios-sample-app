//
//  OWUserMentionTextData.swift
//  SpotImCore
//
//  Created by Refael Sommer on 06/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

struct OWUserMentionTextData {
    let text: String
    let cursorRange: Range<String.Index>
    let replacingText: String?

    var textToCursor: String {
        guard self.cursorRange.upperBound < self.text.utf16.endIndex else { return text }
        return String(String(text.utf16)[..<cursorRange.lowerBound])
    }

    var fullText: String {
        guard self.cursorRange.upperBound < self.text.utf16.endIndex else { return text }
        return textToCursor + String(String(text.utf16)[cursorRange.upperBound...])
    }
}
