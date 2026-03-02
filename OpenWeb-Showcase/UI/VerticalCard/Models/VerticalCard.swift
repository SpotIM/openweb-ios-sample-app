//
//  VerticalCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

struct VerticalCard: Identifiable, Hashable {
    var id: String
    var icon: String
    var title: String
    var description: String = ""
    var color: Color
}
