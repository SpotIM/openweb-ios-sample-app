//
//  OWCommentThreadSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Shprung on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public struct OWCommentThreadSettingsBuilder {
    public var performActionType: OWCommentThreadPerformActionType

    public init(performActionType: OWCommentThreadPerformActionType = .none) {
        self.performActionType = performActionType
    }

    @discardableResult public mutating func performActionType(_ type: OWCommentThreadPerformActionType) -> OWCommentThreadSettingsBuilder {
        self.performActionType = type
        return self
    }

    public func build() -> OWCommentThreadSettingsProtocol {
        return OWCommentThreadSettings(performActionType: performActionType)
    }
}
