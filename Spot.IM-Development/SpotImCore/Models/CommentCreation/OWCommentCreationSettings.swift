//
//  OWCommentCreationSettings.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

public struct OWCommentCreationSettings: OWCommentCreationSettingsProtocol {
    public let style: OWCommentCreationStyle

    public init(style: OWCommentCreationStyle = .regular) {
        self.style = style
    }
}
