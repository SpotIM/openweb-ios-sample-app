//
//  OWConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWConversationSettingsBuilder: OWConversationSettingsProtocol {
    public var selectedCommentId: String?
    
    public init(selectedCommentId: String? = nil) {
        self.selectedCommentId = selectedCommentId
    }
    
    @discardableResult public mutating func selectedCommentId(id: String?) -> OWConversationSettingsBuilder {
        self.selectedCommentId = id
        return self
    }
}
#endif
