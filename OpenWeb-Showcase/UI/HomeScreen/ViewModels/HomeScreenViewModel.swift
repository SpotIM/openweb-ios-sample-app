//
//  HomeScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

@Observable
class HomeScreenViewModel {
    let verticals: [VerticalCard] = [
        VerticalCard(
            id: "news",
            icon: "📰",
            title: "verticalNewsTitle",
            description: "verticalNewsDescription",
            color: Color("NewsColor")
        ),
        VerticalCard(
            id: "finance",
            icon: "📈",
            title: "verticalFinanceTitle",
            description: "verticalFinanceDescription",
            color: Color("FinanceColor")
        ),
        VerticalCard(
            id: "recipes",
            icon: "🍲",
            title: "verticalRecipesTitle",
            description: "verticalRecipesDescription",
            color: Color("RecipesColor")
        ),
        VerticalCard(
            id: "sport",
            icon: "⚽",
            title: "verticalSportTitle",
            description: "verticalSportDescription",
            color: Color("SportColor")
        ),
        VerticalCard(
            id: "video",
            icon: "▶️",
            title: "verticalVideoTitle",
            description: "verticalVideoDescription",
            color: Color("VideoColor")
        ),
        VerticalCard(
            id: "siderail",
            icon: "📄",
            title: "verticalSiderailTitle",
            description: "verticalSiderailDescription",
            color: Color("SideRailColor")
        ),
    ]
}
