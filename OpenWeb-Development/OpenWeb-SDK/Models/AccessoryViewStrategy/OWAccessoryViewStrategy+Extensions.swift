//
//  OWAccessoryViewStrategy+Extensions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 29/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

extension OWAccessoryViewStrategy {
    static var `default`: OWAccessoryViewStrategy {
        return .none
    }
}

extension OWAccessoryViewStrategy: Codable {

    enum OWAccessoryViewStrategyType: String, Codable {
        case none
        case bottomToolbar
    }

    enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(OWAccessoryViewStrategyType.self, forKey: .type)
        switch type {
        case .none:
            self = .none
        case .bottomToolbar:
            // Since UIView isn't decodable, we will just create an empty View from the decoder
            let toolbar = UIView()
            self = .bottomToolbar(toolbar: toolbar)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .none:
            try container.encode(OWAccessoryViewStrategyType.none, forKey: .type)
        case .bottomToolbar:
            try container.encode(OWAccessoryViewStrategyType.bottomToolbar, forKey: .type)
        }
    }
}
