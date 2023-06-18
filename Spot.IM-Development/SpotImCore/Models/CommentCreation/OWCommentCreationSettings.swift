//
//  OWCommentCreationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWCommentCreationSettings: OWCommentCreationSettingsProtocol {
    public let style: OWCommentCreationStyle

    public init(style: OWCommentCreationStyle = .regular) {
        self.style = style
    }
}
#else
struct OWCommentCreationSettings: OWCommentCreationSettingsProtocol {
    let style: OWCommentCreationStyle

    init(style: OWCommentCreationStyle = .regular) {
        self.style = style
    }
}
#endif
