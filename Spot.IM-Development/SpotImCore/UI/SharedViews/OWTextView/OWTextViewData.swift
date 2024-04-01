//
//  OWTextViewData.swift
//  SpotImCore
//
//  Created by Refael Sommer on 08/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWTextViewData {
    let textViewMaxCharecters: Int
    let placeholderText: String
    let textViewText: String
    let charectersLimitEnabled: Bool
    let showCharectersLimit: Bool
    let isEditable: Bool
    let isAutoExpandable: Bool
    let hasSuggestionsBar: Bool
    let isScrollEnabled: Bool
    let hasBorder: Bool

    init(textViewMaxCharecters: Int = 0,
         placeholderText: String,
         textViewText: String = "",
         charectersLimitEnabled: Bool,
         showCharectersLimit: Bool,
         isEditable: Bool,
         isAutoExpandable: Bool = false,
         hasSuggestionsBar: Bool = true,
         isScrollEnabled: Bool = true,
         hasBorder: Bool = true) {
        self.textViewMaxCharecters = textViewMaxCharecters
        self.placeholderText = placeholderText
        self.textViewText = textViewText
        self.charectersLimitEnabled = charectersLimitEnabled
        self.showCharectersLimit = showCharectersLimit
        self.isEditable = isEditable
        self.isAutoExpandable = isAutoExpandable
        self.hasSuggestionsBar = hasSuggestionsBar
        self.isScrollEnabled = isScrollEnabled
        self.hasBorder = hasBorder
    }
}
