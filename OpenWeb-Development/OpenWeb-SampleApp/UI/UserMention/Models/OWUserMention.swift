//
//  OWUserMention.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 26/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

struct OWUserMentionResponse: Decodable {
    let suggestions: [SPUser]?
}
