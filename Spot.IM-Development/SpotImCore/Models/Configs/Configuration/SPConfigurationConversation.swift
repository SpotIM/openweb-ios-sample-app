//
//  SPConfigurationConversation.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

typealias TranslationTextOverrides = [String : [String : String]]
struct SPConfigurationConversation: Decodable {
    
    let readBatchSize: Int?
    let socialEnable: Bool?
    let typingAggregationTimeSeconds: Int?
    let communityGuidelinesEnabled: Bool?
    let communityGuidelinesTitle: SPCommunityGuidelinesTitle?
    let disableImageUploadButton: Bool?
    let translationTextOverrides: TranslationTextOverrides? // [language: [key : text]]
    let subscriberBadgeConfig: OWSubscriberBadgeConfiguration?
    let disableOnlineDotIndicator: Bool?
    let disableVoteDown: Bool?
    let disableVoteUp: Bool?
    let disableShareComment: Bool?
    
    enum CodingKeys: String, CodingKey {
        case subscriberBadgeConfig = "subscriberBadge"
        case disableShareComment = "disableShare"
        case readBatchSize,
             socialEnable,
             typingAggregationTimeSeconds,
             communityGuidelinesEnabled,
             communityGuidelinesTitle,
             disableImageUploadButton,
             translationTextOverrides,
             disableOnlineDotIndicator,
             disableVoteDown,
             disableVoteUp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        readBatchSize = try? container.decode(Int.self, forKey: .readBatchSize)
        socialEnable = try? container.decode(Bool.self, forKey: .socialEnable)
        typingAggregationTimeSeconds = try? container.decode(Int.self, forKey: .typingAggregationTimeSeconds)
        communityGuidelinesEnabled = try? container.decode(Bool.self, forKey: .communityGuidelinesEnabled)
        communityGuidelinesTitle = try? container.decode(SPCommunityGuidelinesTitle.self, forKey: .communityGuidelinesTitle)
        disableImageUploadButton = try? container.decode(Bool.self, forKey: .disableImageUploadButton)
        translationTextOverrides = try? container.decode(TranslationTextOverrides.self, forKey: .translationTextOverrides)
        subscriberBadgeConfig = try? container.decode(OWSubscriberBadgeConfiguration.self, forKey: .subscriberBadgeConfig)
        disableOnlineDotIndicator = try? container.decode(Bool.self, forKey: .disableOnlineDotIndicator)
        disableVoteDown = try? container.decode(Bool.self, forKey: .disableVoteDown)
        disableVoteUp = try? container.decode(Bool.self, forKey: .disableVoteUp)
        disableShareComment = try? container.decode(Bool.self, forKey: .disableShareComment)
    }
}
