//
//  OWConversationCountersResponse.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWConversationCountersResponse: Codable {
    let counts: [OWPostId: OWConversationCounter]
}
