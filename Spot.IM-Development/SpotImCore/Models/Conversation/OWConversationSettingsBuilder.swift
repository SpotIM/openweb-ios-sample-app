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
    public var style: OWConversationStyle

    public init(style: OWConversationStyle = .regular, selectedCommentId: String? = nil) {
        self.selectedCommentId = selectedCommentId
        self.style = style
    }

    @discardableResult public mutating func selectedCommentId(id: String?) -> OWConversationSettingsBuilder {
        self.selectedCommentId = id
        return self
    }

    @discardableResult public mutating func style(_ style: OWConversationStyle) -> OWConversationSettingsBuilder {
        self.style = style
        return self
    }
}
#else
struct OWConversationSettingsBuilder: OWConversationSettingsProtocol {
    var selectedCommentId: String?
    var style: OWConversationStyle

    init(style: OWConversationStyle = .regular, selectedCommentId: String? = nil) {
        self.selectedCommentId = selectedCommentId
        self.style = style
    }

    @discardableResult mutating func selectedCommentId(id: String?) -> OWConversationSettingsBuilder {
        self.selectedCommentId = id
        return self
    }

    @discardableResult mutating func style(_ style: OWConversationStyle) -> OWConversationSettingsBuilder {
        self.style = style
        return self
    }
}
#endif
