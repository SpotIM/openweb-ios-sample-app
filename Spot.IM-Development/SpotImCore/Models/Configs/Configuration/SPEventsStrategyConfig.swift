//
//  SPEventsStrategyConfig.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 10/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct SPEventsStrategyConfig: Decodable {
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
