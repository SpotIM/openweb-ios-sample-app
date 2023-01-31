//
//  OWConversationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWConversationSettings: OWConversationSettingsProtocol {
    public let selectedCommentId: String?
    public let style: OWConversationStyle
    
    public init(style: OWConversationStyle = .regular, selectedCommentId: String? = nil) {
        self.selectedCommentId = selectedCommentId
        self.style = style
    }
}
#else
struct OWConversationSettings: OWConversationSettingsProtocol {
    let selectedCommentId: String?
    public let style: OWConversationStyle
    
    init(style: OWConversationStyle = .regular, selectedCommentId: String? = nil) {
        self.selectedCommentId = selectedCommentId
        self.style = style
    }
}
#endif
