//
//  OWUserMentionCreationData.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 06/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

class OWUserMentionData {
    var tappedMentionString: String?
    var mentions: [OWUserMentionObject] = []
}

class OWUserMentionObject {
    let id: String
    let userId: String
    let text: String
    var range: NSRange

    init(id: String, userId: String, text: String, range: NSRange) {
        self.id = id
        self.userId = userId
        self.text = text
        self.range = range
    }

    var jsonString: String {
        return "@{\"id\": \"\(id)\"}"
    }
}
