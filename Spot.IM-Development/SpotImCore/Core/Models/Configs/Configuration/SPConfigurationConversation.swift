//
//  SPConfigurationConversation.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationConversation: Decodable {
    
    let readBatchSize: Int?
    let socialEnable: Bool?
    let typingAggregationTimeSeconds: Int?
    let communityGuidelinesEnabled: Bool?
    let communityGuidelinesTitle: SPCommunityGuidelinesTitle?
}
