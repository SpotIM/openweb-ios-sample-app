//
//  ShowcaseVertical.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum ShowcaseVertical: Identifiable, CaseIterable, Hashable {
    case news
    case finance
    case recipes
    case sport
    case video
    case sideRail

    var id: Self { self }

    // MARK: - Card Properties

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

    var title: LocalizedStringResource {
        switch self {
        case .news: .verticalNewsTitle
        case .finance: .verticalFinanceTitle
        case .recipes: .verticalRecipesTitle
        case .sport: .verticalSportTitle
        case .video: .verticalVideoTitle
        case .sideRail: .verticalSiderailTitle
        }
    }

    var description: LocalizedStringResource {
        switch self {
        case .news: .verticalNewsDescription
        case .finance: .verticalFinanceDescription
        case .recipes: .verticalRecipesDescription
        case .sport: .verticalSportDescription
        case .video: .verticalVideoDescription
        case .sideRail: .verticalSiderailDescription
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

    // MARK: - Article Data

    var article: ArticleData {
        switch self {
        case .news:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "news_1",
                title: "Breaking: Major Policy Changes Expected Next Week",
                content: ArticleContent(
                    imageURL: "https://images.unsplash.com/photo-1504711434969-e33886168d5c?w=800&q=80",
                    sourceName: "The Daily Tribune",
                    readTime: "4 min read",
                    subtitle: "Government officials announce sweeping reforms that could reshape the economic landscape",
                    authorName: "Rachel Adams",
                    date: "Dec 9, 2025",
                    leadParagraph: Self.loadArticle(named: "news_lead")
                )
            )
        case .finance:
            ArticleData(
                spotId: "sp_xT4NGStS",
                postId: "finance_1",
                title: "Apple Stock Surges Amid Strong Q4 Earnings Report",
                content: ArticleContent(
                    imageURL: "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&q=80",
                    sourceName: "Market Watch Daily",
                    readTime: "5 min read",
                    subtitle: "Services segment drives record revenue as Wall Street raises price targets",
                    authorName: "Marcus Webb",
                    date: "Dec 9, 2025",
                    leadParagraph: Self.loadArticle(named: "finance_lead")
                )
            )
        case .recipes:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "recipes_1",
                title: "The Ultimate Homemade Pasta Recipe Everyone Loves",
                content: ArticleContent(
                    imageURL: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80",
                    sourceName: "Taste & Table",
                    readTime: "6 min read",
                    subtitle: "From silky fettuccine to perfect ravioli — master fresh pasta with this foolproof guide",
                    authorName: "Sofia Caruso",
                    date: "Dec 8, 2025",
                    leadParagraph: Self.loadArticle(named: "recipes_lead")
                )
            )
        case .sport:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "sport_1",
                title: "Champions League Final: Preview and Predictions"
            )
        case .video:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "video_1",
                title: "Big Buck Bunny - Animated Short Film"
            )
        case .sideRail:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "siderail_1",
                title: "The Future of Remote Work: A Deep Dive",
                content: ArticleContent(
                    imageURL: "https://images.unsplash.com/photo-1587560699334-cc4ff634909a?w=800&q=80",
                    sourceName: "Future of Work",
                    readTime: "7 min read",
                    subtitle: "How organizations are reimagining productivity, collaboration, and work-life balance",
                    authorName: "Jordan Lee",
                    date: "Dec 7, 2025",
                    leadParagraph: ""
                )
            )
        }
    }

    // MARK: - SDK Usage Info

    var sdkUsageInfo: SDKUsageInfo {
        switch self {
        case .news:
            SDKUsageInfo(
                subtitle: "Pre-Conversation Module – Compact Mode",
                description: """
                This implementation gently introduces the conversation without distracting users from the article itself.
                By showing social signals like comment count and active participants, readers are more likely to join the discussion once they finish reading.

                Why choose this implementation?

                Perfect for publishers who want higher engagement while keeping a clean, editorial-first experience.
                """
            )
        case .finance:
            SDKUsageInfo(
                subtitle: "Sentiment-Based Comments",
                description: """
                This implementation adds sentiment labels (Bullish, Neutral, Bearish) to comments, helping users quickly understand the overall tone of the discussion.

                By summarizing sentiment before entering the full conversation, readers can grasp market perspectives at a glance and decide how deeply they want to engage.

                This model works especially well for financial content where insight, clarity, and trend awareness add direct value to the reading experience.
                """
            )
        case .recipes:
            SDKUsageInfo(
                subtitle: "Rating Summary + Star Reviews",
                description: """
                This implementation combines star ratings with written comments and a summarized rating overview, turning the conversation into a source of practical feedback.

                Users can quickly evaluate how others experienced the recipe before reading individual reviews or contributing their own.

                It is particularly effective for lifestyle content where social proof and shared experiences help users make confident decisions.
                """
            )
        case .sport:
            SDKUsageInfo(
                subtitle: "Partial screen implementation",
                description: """
                This implementation places the conversation directly alongside the content - in this example, \
                live match data, removing any friction between content consumption and participation.

                Users can react and comment in real time while following the game, creating a fast-paced and highly engaging second-screen experience.

                This setup is best suited for live events where immediacy and momentum are key drivers of engagement.
                """
            )
        case .video:
            SDKUsageInfo(
                subtitle: "Bottom Sheet Overlay",
                description: """
                This implementation opens the full conversation in a bottom-sheet overlay triggered by a floating comment icon, allowing users to engage without leaving the video.

                The experience mirrors modern social video platforms, keeping users immersed while making participation easily accessible.

                It is ideal for video-first products that want to increase interaction without impacting watch time or content flow.
                """
            )
        case .sideRail:
            SDKUsageInfo(
                subtitle: "Side Rail Panel",
                description: """
                This implementation separates content and conversation into a side rail, enabling users to read and engage simultaneously without cluttering the main article view.

                The conversation is revealed only when the user chooses to open it, giving full control over the reading experience.

                This approach works well for long-form or premium content where thoughtful discussion should complement, not disrupt, consumption.
                """
            )
        }
    }
}

// MARK: - Articles

extension ShowcaseVertical {
    static func loadArticle(named name: String) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }
}
