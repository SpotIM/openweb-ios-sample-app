//
//  OWUserMention.swift
//  SpotImCore
//
//  Created by Refael Sommer on 26/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation

struct OWUserMentionResponse: Decodable {
    let suggestions: [OWUserMention]?
}

struct OWUserMention: Decodable {
    let id: String
    let displayName: String
    let imageId: String
    let online: Bool
    let userName: String
}
