//
//  OWCommentThreadSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Shprung on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentThreadSettingsBuilder: OWCommentThreadSettingsProtocol {
    public var conversationSettings: OWConversationSettingsProtocol

    public init(conversationSettings: OWConversationSettingsProtocol, style: OWCommentCreationStyle = .regular) {
        self.conversationSettings = conversationSettings
    }

    @discardableResult public mutating func conversationSettings(_ settings: OWConversationSettingsProtocol) -> OWCommentThreadSettingsBuilder {
        self.conversationSettings = settings
        return self
    }
}
#else
struct OWCommentThreadSettingsBuilder: OWCommentThreadSettingsProtocol {
    var conversationSettings: OWConversationSettingsProtocol

    init(conversationSettings: OWConversationSettingsProtocol) {
        self.conversationSettings = conversationSettings
    }

    @discardableResult mutating func conversationSettings(_ settings: OWConversationSettingsProtocol) -> OWCommentThreadSettingsBuilder {
        self.conversationSettings = settings
        return self
    }
}
#endif
