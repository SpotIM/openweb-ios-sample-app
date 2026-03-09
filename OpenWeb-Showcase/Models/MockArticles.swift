//
//  MockArticles.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum MockArticles {
    static func news() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_LmNIcv7z",
                postId: "news_1"
            ),
            title: "Government officials announce sweeping reforms that could reshape the economic landscape",
            body: loadArticle(named: "news")
        )
    }

    static func finance() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_xT4NGStS",
                postId: "finance_1"
            ),
            title: "Apple Stock Surges Amid Strong Q4 Earnings Report.",
            body: loadArticle(named: "finance")
        )
    }

    static func recipes() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_LmNIcv7z",
                postId: "recipes_1"
            ),
            title: "The Ultimate Homemade Pasta Recipe Everyone Loves",
            body: loadArticle(named: "recipes")
        )
    }

    static func sport() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_LmNIcv7z",
                postId: "sport_1"
            ),
            title: "Champions League Final: Preview and Predictions",
            body: ""
        )
    }

    static func video() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_LmNIcv7z",
                postId: "video_1"
            ),
            title: "Big Buck Bunny - Animated Short Film",
            body: loadArticle(named: "video")
        )
    }

    static func sideRail() -> ArticleData {
        ArticleData(
            conversationIds: ConversationIdentifiers(
                spotId: "sp_LmNIcv7z",
                postId: "siderail_1"
            ),
            title: "The Future of Remote Work: A Deep Dive",
            body: loadArticle(named: "siderail")
        )
    }
}

// MARK: - Private

private extension MockArticles {
    static func loadArticle(named name: String) -> String {
        guard let url = Bundle.main.url(forResource: name, withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return ""
        }
        return content
    }
}
