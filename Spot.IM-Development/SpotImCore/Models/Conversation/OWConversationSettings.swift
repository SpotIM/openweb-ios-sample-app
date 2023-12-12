//
//  OWConversationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public struct OWConversationSettings: OWConversationSettingsProtocol {
    public let style: OWConversationStyle

    public init(style: OWConversationStyle = .regular) {
        self.style = style.validate()
    }
}
