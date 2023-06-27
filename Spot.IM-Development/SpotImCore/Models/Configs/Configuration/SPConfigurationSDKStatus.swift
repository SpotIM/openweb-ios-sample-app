//
//  SPConfigurationSDKStatus.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/29/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

struct SPConfigurationSDKStatus: Decodable {
    let enabled: Bool?
    let locale: String?
    let realtimeEnabled: Bool?
    let blitzEnabled: Bool?
    let loginUiEnabled: Bool?
    let disableInterstitialOnLogin: Bool?
    let openwebWebsiteUrl: String
    let openwebPrivacyUrl: String
    let openwebTermsUrl: String
    let googleAdsProviderRequired: Bool?
    let disableAdsForSubscribers: Bool?
    let profileEnabled: Bool?
    let imageUploadBaseUrl: String
    let fetchImageBaseUrl: String
    let shouldShowCommentCounter: Bool
    let commentCounterCharactersLimit: Int
    let eventsStrategyConfig: EventsStrategyConfig?
}

struct EventsStrategyConfig: Decodable {
    let blockVersionsEqualOrPrevious: OWVersion?
    let blockEventsByVersion: Dictionary<OWVersion, [String]>?

    enum CodingKeys: String, CodingKey {
        case blockVersionsEqualOrPrevious, blockEventsByVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        blockVersionsEqualOrPrevious = try? container.decode(OWVersion.self, forKey: .blockVersionsEqualOrPrevious)
        let stringDictionary = try? container.decode([String: [String]].self, forKey: .blockEventsByVersion)

        var dictionary: [OWVersion: [String]] = [:]
        if let stringDictionary = stringDictionary {
            for (stringKey, value) in stringDictionary {
              guard let key = OWVersion(from: stringKey) else {
                  throw DecodingError.dataCorruptedError(forKey: .blockEventsByVersion,
                  in: container,
                  debugDescription: "Invalid key '\(stringKey)'"
                )
              }
              dictionary[key] = value
            }
        }
        blockEventsByVersion = dictionary
    }
}
