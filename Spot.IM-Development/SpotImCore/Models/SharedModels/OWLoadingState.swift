//
//  OWLoadingState.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWLoadingState {
    case notLoading
    case loading(triggredBy: OWLoadingTriggeredReason)
}

extension OWLoadingState: Equatable {
    static func == (lhs: OWLoadingState, rhs: OWLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.notLoading, .notLoading):
            return true
        case (let .loading(lhsTriggredBy), let .loading(rhsTriggredBy)):
            return lhsTriggredBy == rhsTriggredBy
        default:
            return false
        }
    }
}
