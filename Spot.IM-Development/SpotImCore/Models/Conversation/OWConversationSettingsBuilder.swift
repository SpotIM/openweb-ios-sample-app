//
//  OWConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWConversationSettingsBuilder {
    public var style: OWConversationStyle

    public init(style: OWConversationStyle = .regular) {
        self.style = style
    }

    @discardableResult public mutating func style(_ style: OWConversationStyle) -> OWConversationSettingsBuilder {
        self.style = style
        return self
    }

    public func build() -> OWConversationSettingsProtocol {
        return OWConversationSettings(style: style)
    }
}
#else
struct OWConversationSettingsBuilder {
    var style: OWConversationStyle

    init(style: OWConversationStyle = .regular) {
        self.style = style
    }

    @discardableResult mutating func style(_ style: OWConversationStyle) -> OWConversationSettingsBuilder {
        self.style = style
        return self
    }

    func build() -> OWConversationSettingsProtocol {
        return OWConversationSettings(style: style)
    }
}

#endif
