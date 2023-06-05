//
//  OWPreConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWPreConversationSettingsBuilder {
    public var style: OWPreConversationStyle
    public var fullConversationSettings: OWConversationSettingsProtocol

    public init(style: OWPreConversationStyle = .regular,
                fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettingsBuilder().build()) {
        self.style = style.validate()
        self.fullConversationSettings = fullConversationSettings
    }

    @discardableResult public mutating func style(_ style: OWPreConversationStyle) -> OWPreConversationSettingsBuilder {
        self.style = style.validate()
        return self
    }

    @discardableResult public mutating func conversationSettings(_ conversationSettings: OWConversationSettingsProtocol) -> OWPreConversationSettingsBuilder {
        self.fullConversationSettings = conversationSettings
        return self
    }

    public func build() -> OWPreConversationSettingsProtocol {
        return OWPreConversationSettings(style: style,
                                         fullConversationSettings: fullConversationSettings)
    }
}
#else
struct OWPreConversationSettingsBuilder {
    var style: OWPreConversationStyle
    var fullConversationSettings: OWConversationSettingsProtocol

    init(style: OWPreConversationStyle = .regular,
         fullConversationSettings: fullConversationSettings = OWConversationSettingsBuilder().build()) {
        self.style = style.validate()
        self.fullConversationSettings = fullConversationSettings
    }

    @discardableResult mutating func style(_ style: OWPreConversationStyle) -> OWPreConversationSettingsBuilder {
        self.style = style.validate()
        return self
    }

    func build() -> OWPreConversationSettingsProtocol {
        return OWPreConversationSettings(style: style, fullConversationSettings: fullConversationSettings)
    }
}
#endif
