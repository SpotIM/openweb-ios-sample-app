//
//  OWCommentCreationStyle+Extensions.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

#if NEW_API

extension OWCommentCreationStyle {
    static func commentCreationStyle(fromIndex index: Int,
                                     commonCreatorService: CommonCreatorServicing = CommonCreatorService()) -> OWCommentCreationStyle {
        switch index {
        case OWCommentCreationStyleIndexer.regular.index: return .regular
        case OWCommentCreationStyleIndexer.light.index: return .light
        case OWCommentCreationStyleIndexer.floatingKeyboard.index:
            let toolbar = commonCreatorService.commentCreationFloatingBottomToolbar().1
            // TODO: Add in the settings screen an option to select our customized bottom toolbar or none
            return .floatingKeyboard(accessoryViewStrategy: .bottomToolbar(toolbar: toolbar))
        default: return .regular
        }
    }

    static var `default`: OWCommentCreationStyle {
        return .regular
    }
}

#endif
