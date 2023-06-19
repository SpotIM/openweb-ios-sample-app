//
//  OWAdditionalSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Shprung on 14/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWAdditionalSettingsBuilder {
    public var preConversationSettings: OWPreConversationSettingsProtocol
    public var fullConversationSettings: OWConversationSettingsProtocol
    public var commentCreationSettings: OWCommentCreationSettingsProtocol
    public var commentThreadSettings: OWCommentThreadSettingsProtocol

    public init(preConversationSettings: OWPreConversationSettingsProtocol = OWPreConversationSettingsBuilder().build(),
                fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettingsBuilder().build(),
                commentCreationSettings: OWCommentCreationSettingsProtocol = OWCommentCreationSettingsBuilder().build(),
                commentThreadSettings: OWCommentThreadSettingsProtocol = OWCommentThreadSettingsBuilder().build()
    ) {
        self.preConversationSettings = preConversationSettings
        self.fullConversationSettings = fullConversationSettings
        self.commentCreationSettings = commentCreationSettings
        self.commentThreadSettings = commentThreadSettings
    }

    @discardableResult public mutating func preConversationSettings(_ preConversationSettings: OWPreConversationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.preConversationSettings = preConversationSettings
        return self
    }

    @discardableResult public mutating func conversationSettings(_ conversationSettings: OWConversationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.fullConversationSettings = conversationSettings
        return self
    }

    @discardableResult public mutating func commentCreationSettings(_ commentCreationSettings: OWCommentCreationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.commentCreationSettings = commentCreationSettings
        return self
    }

    @discardableResult public mutating func commentThreadSettings(_ commentThreadSettings: OWCommentThreadSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.commentThreadSettings = commentThreadSettings
        return self
    }

    public func build() -> OWAdditionalSettingsProtocol {
        return OWAdditionalSettings()
    }
}
#else
struct OWAdditionalSettingsBuilder {
    var preConversationSettings: OWPreConversationSettingsProtocol
    var fullConversationSettings: OWConversationSettingsProtocol
    var commentCreationSettings: OWCommentCreationSettingsProtocol
    var commentThreadSettings: OWCommentThreadSettingsProtocol

    init(preConversationSettings: OWPreConversationSettingsProtocol = OWPreConversationSettingsBuilder().build(),
         fullConversationSettings: OWConversationSettingsProtocol = OWConversationSettingsBuilder().build(),
         commentCreationSettings: OWCommentCreationSettingsProtocol = OWCommentCreationSettingsBuilder().build(),
         commentThreadSettings: OWCommentThreadSettingsProtocol = OWCommentThreadSettingsBuilder().build()
    ) {
        self.preConversationSettings = preConversationSettings
        self.fullConversationSettings = fullConversationSettings
        self.commentCreationSettings = commentCreationSettings
        self.commentThreadSettings = commentThreadSettings
    }

    @discardableResult mutating func preConversationSettings(_ preConversationSettings: OWPreConversationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.preConversationSettings = preConversationSettings
        return self
    }

    @discardableResult mutating func conversationSettings(_ conversationSettings: OWConversationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.fullConversationSettings = conversationSettings
        return self
    }

    @discardableResult mutating func commentCreationSettings(_ commentCreationSettings: OWCommentCreationSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.commentCreationSettings = commentCreationSettings
        return self
    }

    @discardableResult mutating func commentThreadSettings(_ commentThreadSettings: OWCommentThreadSettingsProtocol) -> OWAdditionalSettingsBuilder {
        self.commentThreadSettings = commentThreadSettings
        return self
    }

    func build() -> OWAdditionalSettingsProtocol {
        return OWAdditionalSettings()
    }
}
#endif
