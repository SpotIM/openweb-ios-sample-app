//
//  OWPreConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public struct OWPreConversationSettingsBuilder {
    public var style: OWPreConversationStyle

    public init(style: OWPreConversationStyle = .regular) {
        self.style = style.validate()
    }

    @discardableResult public mutating func style(_ style: OWPreConversationStyle) -> OWPreConversationSettingsBuilder {
        self.style = style.validate()
        return self
    }

    public func build() -> OWPreConversationSettingsProtocol {
        return OWPreConversationSettings(style: style)
    }
}
