//
//  OWPreConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWPreConversationSettingsBuilder: OWPreConversationSettingsProtocol {
    public var numberOfComments: Int
    
    public init(numberOfComments: Int = 2) {
        self.numberOfComments = numberOfComments
    }
    
    @discardableResult public mutating func numberOfComments(num: Int) -> OWPreConversationSettingsBuilder {
        self.numberOfComments = num
        return self
    }
}
#endif
