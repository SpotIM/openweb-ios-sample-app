//
//  OWPreConversationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 31/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWPreConversationStyle {
    public struct Metrics {
        public static let defaultRegularNumberOfComments: Int = 2
        public static let minNumberOfComments: Int = 1
        public static let maxNumberOfComments: Int = 8 // Before the refactor max was 15, 8 seems enough - TODO: Validate with product
    }
    
    case regular(numberOfComments: Int = Metrics.defaultRegularNumberOfComments)
    case compact
    case ctaButtonOnly // Called "Button only mode" - no title, before the refactor
    case ctaWithSummary // Called "Button only mode" - title, before the refactor
}

#else
enum OWPreConversationStyle {
    struct Metrics {
        static let defaultRegularNumberOfComments: Int = 2
        static let minNumberOfComments: Int = 1
        static let maxNumberOfComments: Int = 8 // Before the refactor max was 15, 8 seems enough - TODO: Validate with product
    }
    
    case regular(numberOfComments: Int = Metrics.defaultRegularNumberOfComments)
    case compact
    case ctaButtonOnly // Called "Button only mode" - no title, before the refactor
    case ctaWithSummary // Called "Button only mode" - title, before the refactor
}
#endif
