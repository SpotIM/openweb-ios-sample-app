//
//  OWPreConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWPreConversationSettingsBuilder: OWPreConversationSettingsProtocol {
    var numberOfComments: Int = 2
    
    @discardableResult mutating func numberOfComments(num: Int) -> OWPreConversationSettingsBuilder {
        self.numberOfComments = num
        return self
    }
}
