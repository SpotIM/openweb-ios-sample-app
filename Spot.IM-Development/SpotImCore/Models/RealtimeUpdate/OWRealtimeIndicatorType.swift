//
//  OWRealtimeIndicatorType.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWRealtimeIndicatorType {
    case typing(count: Int)
    case newComments(count: Int)
    case all(typingCount: Int, newCommentsCount: Int)
    case none
}
