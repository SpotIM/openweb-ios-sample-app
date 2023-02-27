//
//  OWPreConversationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    public let style: OWPreConversationStyle

    public init(style: OWPreConversationStyle = .regular()) {
        self.style = style.validate()
    }
}
#else
struct OWPreConversationSettings: OWPreConversationSettingsProtocol {
    let style: OWPreConversationStyle

    init(style: OWPreConversationStyle = .regular()) {
        self.style = style.validate()
    }
}
#endif
