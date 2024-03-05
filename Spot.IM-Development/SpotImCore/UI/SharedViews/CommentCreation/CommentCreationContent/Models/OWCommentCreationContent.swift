//
//  OWCommentCreationContent.swift
//  SpotImCore
//
//  Created by Alon Shprung on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentCreationContent {
    var text: String
    var image: OWCommentImage?
    var gif: OWCommentGif?

    func hasContent() -> Bool {
        let adjustedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !adjustedText.isEmpty || image != nil || gif != nil
    }
}
