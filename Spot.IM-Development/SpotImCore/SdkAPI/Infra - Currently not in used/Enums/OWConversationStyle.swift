//
//  OWConversationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWConversationStyle: Codable {
    case regular
    case compact
    case custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle, communityQuestionsStyle: OWCommunityQuestionStyle, spacing: OWConversationSpacing)
}

#else
enum OWConversationStyle: Codable {
    case regular
    case compact
    case custom(communityGuidelinesStyle: OWCommunityGuidelinesStyle, communityQuestionsStyle: OWCommunityQuestionStyle, spacing: OWConversationSpacing)
}
#endif
