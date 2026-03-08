//
//  VerticalCardData.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalCardData: Identifiable, Hashable {
    var id: String
    var icon: String
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    var color: Color

    static func == (lhs: VerticalCardData, rhs: VerticalCardData) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
