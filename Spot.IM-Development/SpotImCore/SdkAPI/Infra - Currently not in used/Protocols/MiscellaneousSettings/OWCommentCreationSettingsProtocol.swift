//
//  OWCommentCreationSettingsProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWCommentCreationSettingsProtocol {
    var conversationSettings: OWConversationSettingsProtocol { get }
}
#else
protocol OWCommentCreationSettingsProtocol {
    var conversationSettings: OWConversationSettingsProtocol { get }
}
#endif
