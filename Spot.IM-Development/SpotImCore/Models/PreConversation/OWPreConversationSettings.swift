//
//  OWPreConversationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    public let numberOfComments: Int
    
    public init(numberOfComments: Int = 2) {
        self.numberOfComments = numberOfComments
    }
}
#else
struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    let numberOfComments: Int
    
    init(numberOfComments: Int = 2) {
        self.numberOfComments = numberOfComments
    }
}
#endif
