//
//  OWCommentThreadSettingsBuilder.swift
//  SpotImCore
//
//  Created by Alon Shprung on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentThreadSettingsBuilder {

    public init() {

    }

    public func build() -> OWCommentThreadSettingsProtocol {
        return OWCommentThreadSettings()
    }
}
#else
struct OWCommentThreadSettingsBuilder {

    init() {

    }

    func build() -> OWCommentThreadSettingsProtocol {
        return OWCommentThreadSettings()
    }
}
#endif
