//
//  SPConfigurationShared.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationShared: Decodable {
    
    let enableCommentLabels: Bool?
    let commentLabels: Dictionary<String, SPCommentLabelsSectionConfiguration>?
    let votesType: OWVotesType
    let usePublisherUserProfile: Bool?
    
    enum CodingKeys: String, CodingKey {
        case usePublisherUserProfile = "useCustomUserProfile"
        case enableCommentLabels,
             commentLabels,
             votesType
    }
}
