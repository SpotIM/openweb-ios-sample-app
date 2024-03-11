//
//  OWUserMentionCreationData.swift
//  SpotImCore
//
//  Created by Refael Sommer on 06/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

class OWUserMentionData {
    var tappedMentionString: String?
    var mentions: [OWUserMentionObject] = []
}

class OWUserMentionObject {
    let id: String
    let text: String
    var range: NSRange

    init(id: String, text: String, range: NSRange) {
        self.id = id
        self.text = text
        self.range = range
    }
}
