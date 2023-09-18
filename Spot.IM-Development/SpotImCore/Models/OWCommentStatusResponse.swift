//
//  OWCommentStatusResponse.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentStatusResponse: Decodable {
    let messageId: String
    let status: String
}
