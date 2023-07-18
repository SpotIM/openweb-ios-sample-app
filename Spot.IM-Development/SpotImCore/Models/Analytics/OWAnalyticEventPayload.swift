//
//  OWAnalyticEventPayload.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 18/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWAnalyticEventPayload: Encodable {
    var payloadDictionary: [String: Encodable] = [:]

    enum CodingKeys: CodingKey {
            case payloadDictionary
        }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode each value in the payload dictionary
        for (key, value) in payloadDictionary {
            encode(value: value, forKey: key, container: &container)
        }
    }

    private func encode(value: Encodable, forKey key: String, container: inout KeyedEncodingContainer<CodingKeys>) {
        if let codingKey = CodingKeys(stringValue: key) {
            try? container.encode(value, forKey: codingKey)
        }
    }
}
