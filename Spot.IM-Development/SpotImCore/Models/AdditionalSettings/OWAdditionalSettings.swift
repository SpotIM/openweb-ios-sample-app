//
//  OWAdditionalSettings.swift
//  SpotImCore
//
//  Created by Alon Shprung on 14/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWAdditionalSettings: OWAdditionalSettingsProtocol {
    public let preConversationSettings: OWPreConversationSettingsProtocol
    public let fullConversationSettings: OWConversationSettingsProtocol
    public let commentCreationSettings: OWCommentCreationSettingsProtocol
    public let commentThreadSettings: OWCommentThreadSettingsProtocol
    
    public init(preConversationSettings: OWPreConversationSettingsProtocol = OWPreConversationSettings(),
                fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettings(),
                commentCreationSettings: OWCommentCreationSettingsProtocol = OWCommentCreationSettings(),
                commentThreadSettings: OWCommentThreadSettingsProtocol = OWCommentThreadSettings()
    ) {
        self.preConversationSettings = preConversationSettings
        self.fullConversationSettings = fullConversationSettings
        self.commentCreationSettings = commentCreationSettings
        self.commentThreadSettings = commentThreadSettings
    }
}
#else
struct OWAdditionalSettings: OWAdditionalSettingsProtocol {
    let preConversationSettings: OWPreConversationSettingsProtocol
    let fullConversationSettings: OWConversationSettingsProtocol
    let commentCreationSettings: OWCommentCreationSettingsProtocol
    let commentThreadSettings: OWCommentThreadSettingsProtocol

    init(preConversationSettings: OWPreConversationSettingsProtocol = OWPreConversationSettings(),
                fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettings(),
                commentCreationSettings: OWCommentCreationSettingsProtocol = OWCommentCreationSettings(),
                commentThreadSettings: OWCommentThreadSettingsProtocol = OWCommentThreadSettings()
    ) {
        self.preConversationSettings = preConversationSettings
        self.fullConversationSettings = fullConversationSettings
        self.commentCreationSettings = commentCreationSettings
        self.commentThreadSettings = commentThreadSettings
    }
}
#endif
