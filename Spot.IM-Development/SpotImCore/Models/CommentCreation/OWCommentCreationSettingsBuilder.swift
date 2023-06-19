//
//  OWCommentCreationSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentCreationSettingsBuilder {
    public var style: OWCommentCreationStyle

    public init(style: OWCommentCreationStyle = .regular) {
        self.style = style
    }

    @discardableResult public mutating func style(_ style: OWCommentCreationStyle) -> OWCommentCreationSettingsBuilder {
        self.style = style
        return self
    }

    public func build() -> OWCommentCreationSettingsProtocol {
        return OWCommentCreationSettings(style: style)
    }
}
#else
struct OWCommentCreationSettingsBuilder {
    var style: OWCommentCreationStyle

    init(style: OWCommentCreationStyle = .regular) {
        self.style = style
    }

    @discardableResult mutating func style(_ style: OWCommentCreationStyle) -> OWCommentCreationSettingsBuilder {
        self.style = style
        return self
    }

    func build() -> OWCommentCreationSettingsProtocol {
        return OWCommentCreationSettings(style: style)
    }
}
#endif
