//
//  OWPreConversationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    public let style: OWPreConversationStyle
    public let fullConversationSettings: OWConversationSettingsProtocol

    public init(style: OWPreConversationStyle = .regular,
                fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettings()) {
        self.style = style.validate()
        self.fullConversationSettings = fullConversationSettings
    }
}
