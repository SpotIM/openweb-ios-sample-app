//
//  HomeScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class HomeScreenViewModel: ObservableObject {
    let verticals: [VerticalCardData] = [
        VerticalCardData(
            id: "news",
            icon: "📰",
            title: "verticalNewsTitle",
            description: "verticalNewsDescription",
            color: Color(.news)
        ),
        VerticalCardData(
            id: "finance",
            icon: "📈",
            title: "verticalFinanceTitle",
            description: "verticalFinanceDescription",
            color: Color(.finance)
        ),
        VerticalCardData(
            id: "recipes",
            icon: "🍲",
            title: "verticalRecipesTitle",
            description: "verticalRecipesDescription",
            color: Color(.recipes)
        ),
        VerticalCardData(
            id: "sport",
            icon: "⚽",
            title: "verticalSportTitle",
            description: "verticalSportDescription",
            color: Color(.sport)
        ),
        VerticalCardData(
            id: "video",
            icon: "▶️",
            title: "verticalVideoTitle",
            description: "verticalVideoDescription",
            color: Color(.video)
        ),
        VerticalCardData(
            id: "siderail",
            icon: "📄",
            title: "verticalSiderailTitle",
            description: "verticalSiderailDescription",
            color: Color(.sideRail)
        ),
    ]
}
