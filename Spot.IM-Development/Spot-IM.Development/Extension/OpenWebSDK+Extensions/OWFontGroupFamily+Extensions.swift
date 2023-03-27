//
//  OWFontGroupFamily+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWFontGroupFamily {
    static func fontGroupFamily(fromIndex index: Int, name: String = "") -> OWFontGroupFamily {
        switch index {
        case 0: return .default
        case 1: return .custom(fontFamily: name)
        default: return .default
        }
    }

    static func fontGroupFamily(fromData data: Data) -> OWFontGroupFamily {
        do {
            let decoded = try JSONDecoder().decode(OWFontGroupFamily.self, from: data)
            return decoded
        } catch {
            DLog("Failed to decode fontGroupFamily \(error.localizedDescription)")
        }
        return .default
    }

    var data: Data {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            DLog("Failed to encode fontGroupFamily \(error.localizedDescription)")
        }
        return Data()
    }

    enum CodingKeys: String, CodingKey {
        case `default`
        case custom
    }
}

#endif
