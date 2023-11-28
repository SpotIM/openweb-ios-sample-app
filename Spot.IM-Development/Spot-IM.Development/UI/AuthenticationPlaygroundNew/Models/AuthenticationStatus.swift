//
//  AuthenticationStatus.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

enum AuthenticationStatus {
    case initial, inProgress, successful, failed

    var symbol: String {
        switch self {
        case .initial:
            return "🔘"
        case .inProgress:
            return "⏳"
        case .successful:
            return "✅"
        case .failed:
            return "❌"
        }
    }
}
