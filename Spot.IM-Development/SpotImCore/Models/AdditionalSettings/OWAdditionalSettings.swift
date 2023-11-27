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
    public var preConversationSettings: OWPreConversationSettingsProtocol
    public var fullConversationSettings: OWConversationSettingsProtocol
    public var commentCreationSettings: OWCommentCreationSettingsProtocol
    public var commentThreadSettings: OWCommentThreadSettingsProtocol

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
    var preConversationSettings: OWPreConversationSettingsProtocol
    var fullConversationSettings: OWConversationSettingsProtocol
    var commentCreationSettings: OWCommentCreationSettingsProtocol
    var commentThreadSettings: OWCommentThreadSettingsProtocol

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
