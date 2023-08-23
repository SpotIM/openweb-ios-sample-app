//
//  OWRealTimeError.swift
//  SpotImCore
//
//  Created by Revital Pisman on 06/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWRealTimeError: Error, CustomStringConvertible {
    case conversationNotFound
    case corruptedData
    case onlineViewingUsersNotFound

    var description: String {
        switch self {
        case .conversationNotFound:
            return "conversationNotFound"
        case .corruptedData:
            return "corruptedData"
        case .onlineViewingUsersNotFound:
            return "onlineUsersViewingNotFound"
        }
    }
}
