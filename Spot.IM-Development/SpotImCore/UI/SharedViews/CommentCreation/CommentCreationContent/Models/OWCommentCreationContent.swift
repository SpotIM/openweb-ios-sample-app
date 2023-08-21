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
    var image: OWComment.Content.Image?

    func hasContent() -> Bool {
        return !text.isEmpty || image != nil
    }
}
