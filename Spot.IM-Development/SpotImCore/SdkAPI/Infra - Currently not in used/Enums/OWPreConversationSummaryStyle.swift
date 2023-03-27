//
//  OWPreConversationSummaryStyle.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 14/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWPreConversationSummaryStyle {
    case none
    case regular
    case compact
}

#else
enum OWPreConversationSummaryStyle {
    case none
    case regular
    case compact
}
#endif
