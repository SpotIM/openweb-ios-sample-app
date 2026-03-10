//
//  SampleVertical.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum SampleVertical: Identifiable, CaseIterable, Hashable {
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
                title: "Government officials announce sweeping reforms that could reshape the economic landscape",
                body: Self.loadArticle(named: "news")
            )
        case .finance:
            ArticleData(
                spotId: "sp_xT4NGStS",
                postId: "finance_1",
                title: "Apple Stock Surges Amid Strong Q4 Earnings Report.",
                body: Self.loadArticle(named: "finance")
            )
        case .recipes:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "recipes_1",
                title: "The Ultimate Homemade Pasta Recipe Everyone Loves",
                body: Self.loadArticle(named: "recipes")
            )
        case .sport:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "sport_1",
                title: "Champions League Final: Preview and Predictions",
                body: ""
            )
        case .video:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "video_1",
                title: "Big Buck Bunny - Animated Short Film",
                body: Self.loadArticle(named: "video")
            )
        case .sideRail:
            ArticleData(
                spotId: "sp_LmNIcv7z",
                postId: "siderail_1",
                title: "The Future of Remote Work: A Deep Dive",
                body: Self.loadArticle(named: "siderail")
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

// MARK: - Private

private extension SampleVertical {
    static func loadArticle(named name: String) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }
}
