//
//  VerticalCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalCard: Identifiable, Hashable {
    var id: String
    var icon: String
    var title: String
    var description: String = ""
    var color: Color
}
