//
//  OWCommentCreationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentCreationSettingsBuilder: OWCommentCreationSettingsProtocol {
    public var conversationSettings: OWConversationSettingsProtocol
    public var style: OWCommentCreationStyle

    public init(conversationSettings: OWConversationSettingsProtocol, style: OWCommentCreationStyle = .regular) {
        self.conversationSettings = conversationSettings
        self.style = style
    }

    @discardableResult public mutating func conversationSettings(_ settings: OWConversationSettingsProtocol) -> OWCommentCreationSettingsProtocol {
        self.conversationSettings = settings
        return self
    }

    @discardableResult public mutating func style(_ style: OWCommentCreationStyle) -> OWCommentCreationSettingsProtocol {
        self.style = style
        return self
    }
}
#else
struct OWCommentCreationSettingsBuilder: OWCommentCreationSettingsProtocol {
    var conversationSettings: OWConversationSettingsProtocol
    var style: OWCommentCreationStyle

    init(conversationSettings: OWConversationSettingsProtocol, style: OWCommentCreationStyle = .regular) {
        self.conversationSettings = conversationSettings
        self.style = style
    }

    @discardableResult mutating func conversationSettings(_ settings: OWConversationSettingsProtocol) -> OWCommentCreationSettingsProtocol {
        self.conversationSettings = settings
        return self
    }

    @discardableResult mutating func style(_ style: OWCommentCreationStyle) -> OWCommentCreationSettingsProtocol {
        self.style = style
        return self
    }
}
#endif
