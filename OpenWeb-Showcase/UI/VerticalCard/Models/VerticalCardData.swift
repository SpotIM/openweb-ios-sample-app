//
//  VerticalCardData.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum VerticalCardData: Identifiable, CaseIterable, Hashable {
    case news
    case finance
    case recipes
    case sport
    case video
    case sideRail

    var id: Self { self }

    var icon: String {
        switch self {
        case .news: "📰"
        case .finance: "📈"
        case .recipes: "🍲"
        case .sport: "⚽"
        case .video: "▶️"
        case .sideRail: "📄"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .news: "verticalNewsTitle"
        case .finance: "verticalFinanceTitle"
        case .recipes: "verticalRecipesTitle"
        case .sport: "verticalSportTitle"
        case .video: "verticalVideoTitle"
        case .sideRail: "verticalSiderailTitle"
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .news: "verticalNewsDescription"
        case .finance: "verticalFinanceDescription"
        case .recipes: "verticalRecipesDescription"
        case .sport: "verticalSportDescription"
        case .video: "verticalVideoDescription"
        case .sideRail: "verticalSiderailDescription"
        }
    }

    var color: Color {
        switch self {
        case .news: Color(.news)
        case .finance: Color(.finance)
        case .recipes: Color(.recipes)
        case .sport: Color(.sport)
        case .video: Color(.video)
        case .sideRail: Color(.sideRail)
        }
    }
}
