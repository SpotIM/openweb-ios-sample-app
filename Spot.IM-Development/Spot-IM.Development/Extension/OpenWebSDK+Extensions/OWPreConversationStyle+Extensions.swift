//
//  OWPreConversationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWPreConversationStyle {
    static func preConversationStyle(fromIndex index: Int, numberOfComments: Int = OWPreConversationStyle.Metrics.defaultRegularNumberOfComments) -> OWPreConversationStyle {
        switch index {
        case 0: return .regular(numberOfComments: numberOfComments)
        case 1: return .compact
        case 2: return .ctaButtonOnly
        case 3: return .ctaWithSummary
        default: return .regular()
        }
    }

    static func preConversationStyle(fromData data: Data) -> OWPreConversationStyle {
        do {
            let decoded = try JSONDecoder().decode(OWPreConversationStyle.self, from: data)
            return decoded
        } catch {
            DLog("Failed decoding preConversationStyle \(error.localizedDescription)")
        }
        return .regular()
    }

    var data: Data {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            DLog("Failed encoading preConversationStyle \(error.localizedDescription)")
        }
        return Data()
    }

    enum CodingKeys: String, CodingKey {
        case regular
        case compact
        case ctaButtonOnly
        case ctaWithSummary
    }
}

extension OWPreConversationStyle: Equatable {
    public static func == (lhs: OWPreConversationStyle, rhs: OWPreConversationStyle) -> Bool {
        switch (lhs, rhs) {
        case (.compact, .compact):
            return true
        case (.ctaButtonOnly, .ctaButtonOnly):
            return true
        case (.ctaWithSummary, .ctaWithSummary):
                return true
        case (.regular(let lhsNumOfComments), .regular(let rhsNumOfComments)):
                return lhsNumOfComments == rhsNumOfComments
        default:
            return false
        }
    }
}

#endif
