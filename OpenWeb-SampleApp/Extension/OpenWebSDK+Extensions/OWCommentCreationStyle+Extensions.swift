//
//  OWCommentCreationStyle+Extensions.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 28/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

extension OWCommentCreationStyle {
    static func commentCreationStyle(fromIndex index: Int,
                                     commonCreatorService: CommonCreatorServicing = CommonCreatorService()) -> OWCommentCreationStyle {
        switch index {
        case OWCommentCreationStyleIndexer.regular.index: return .regular
        case OWCommentCreationStyleIndexer.light.index: return .light
        case OWCommentCreationStyleIndexer.floatingKeyboard.index:
            let toolbar = commonCreatorService.commentCreationFloatingBottomToolbar().1
            return .floatingKeyboard(accessoryViewStrategy: .bottomToolbar(toolbar: toolbar))
        default: return .regular
        }
    }

    static var `default`: OWCommentCreationStyle {
        return .regular
    }
}
