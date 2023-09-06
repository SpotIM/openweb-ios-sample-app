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
    let isEditable: Bool
    let isAutoExpandable: Bool
    let hasSuggestionsBar: Bool

    init(textViewMaxCharecters: Int = 0,
         placeholderText: String,
         textViewText: String = "",
         charectersLimitEnabled: Bool,
         isEditable: Bool,
         isAutoExpandable: Bool = false,
         hasSuggestionsBar: Bool = true) {
        self.textViewMaxCharecters = textViewMaxCharecters
        self.placeholderText = placeholderText
        self.textViewText = textViewText
        self.charectersLimitEnabled = charectersLimitEnabled
        self.isEditable = isEditable
        self.isAutoExpandable = isAutoExpandable
        self.hasSuggestionsBar = hasSuggestionsBar
    }
}
