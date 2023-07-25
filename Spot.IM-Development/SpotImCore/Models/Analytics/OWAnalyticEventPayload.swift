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

    enum CodingKeys: String, CodingKey {
        case payloadDictionary
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyStringKey.self)

        // Encode each value in the payload dictionary
        for (key, value) in payloadDictionary {
            encode(value: value, forKey: key, container: &container)
        }
    }
}

fileprivate extension OWAnalyticEventPayload {
    func encode(value: Encodable, forKey key: String, container: inout KeyedEncodingContainer<AnyStringKey>) {
//        if let codingKey = AnyStringKey(stringValue: key) {
            try? container.encode(value, forKey: AnyStringKey(stringValue: key))
//        }
    }
}

struct AnyStringKey: CodingKey, Hashable, ExpressibleByStringLiteral {
    var stringValue: String
    init(stringValue: String) { self.stringValue = stringValue }
    init(_ stringValue: String) { self.init(stringValue: stringValue) }
    var intValue: Int?
    init?(intValue: Int) { return nil }
    init(stringLiteral value: String) { self.init(value) }
}
