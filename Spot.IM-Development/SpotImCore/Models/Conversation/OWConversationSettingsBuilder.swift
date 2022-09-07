//
//  OWConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct OWConversationSettingsBuilder: OWConversationSettingsProtocol {
    var selectedCommentId: String?
    
    @discardableResult mutating func selectedCommentId(id: String?) -> OWConversationSettingsBuilder {
        self.selectedCommentId = id
        return self
    }
}
