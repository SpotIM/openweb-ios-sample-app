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
        return String(text[..<cursorRange.lowerBound])
    }
}
