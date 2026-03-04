//
//  HomeScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

@Observable
class HomeScreenViewModel {
    let verticals: [VerticalCard] = [
        VerticalCard(
            id: "news",
            icon: "📰",
            title: NSLocalizedString("verticalNewsTitle", comment: ""),
            description: NSLocalizedString("verticalNewsDescription", comment: ""),
            color: Color("NewsColor")
        ),
        VerticalCard(
            id: "finance",
            icon: "📈",
            title: NSLocalizedString("verticalFinanceTitle", comment: ""),
            description: NSLocalizedString("verticalFinanceDescription", comment: ""),
            color: Color("FinanceColor")
        ),
        VerticalCard(
            id: "recipes",
            icon: "🍲",
            title: NSLocalizedString("verticalRecipesTitle", comment: ""),
            description: NSLocalizedString("verticalRecipesDescription", comment: ""),
            color: Color("RecipesColor")
        ),
        VerticalCard(
            id: "sport",
            icon: "⚽",
            title: NSLocalizedString("verticalSportTitle", comment: ""),
            description: NSLocalizedString("verticalSportDescription", comment: ""),
            color: Color("SportColor")
        ),
        VerticalCard(
            id: "video",
            icon: "▶️",
            title: NSLocalizedString("verticalVideoTitle", comment: ""),
            description: NSLocalizedString("verticalVideoDescription", comment: ""),
            color: Color("VideoColor")
        ),
        VerticalCard(
            id: "siderail",
            icon: "📄",
            title: NSLocalizedString("verticalSiderailTitle", comment: ""),
            description: NSLocalizedString("verticalSiderailDescription", comment: ""),
            color: Color("SideRailColor")
        ),
    ]
}
