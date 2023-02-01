//
//  OWPreConversationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWPreConversationSettingsBuilder: OWPreConversationSettingsProtocol {
    public var style: OWPreConversationStyle
    
    public init(style: OWPreConversationStyle = .regular()) {
        self.style = style.validate()
    }
    
    @discardableResult public mutating func style(_ style: OWPreConversationStyle) -> OWPreConversationSettingsBuilder {
        self.style = style.validate()
        return self
    }
}
#endif
