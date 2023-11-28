//
//  OWAdditionalSettingsProtocol.swift
//  SpotImCore
//
//  Created by Alon Shprung on 14/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public protocol OWAdditionalSettingsProtocol {
    var preConversationSettings: OWPreConversationSettingsProtocol { get }
    var fullConversationSettings: OWConversationSettingsProtocol { get }
    var commentCreationSettings: OWCommentCreationSettingsProtocol { get }
    var commentThreadSettings: OWCommentThreadSettingsProtocol { get }
}
