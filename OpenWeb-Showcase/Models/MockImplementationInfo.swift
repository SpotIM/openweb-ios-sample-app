//
//  MockImplementationInfo.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum MockImplementationInfo {
    static func news() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Pre-Conversation Module – Compact Mode",
            description: """
            This implementation gently introduces the conversation without distracting users from the article itself.
            By showing social signals like comment count and active participants, readers are more likely to join the discussion once they finish reading.

            Why choose this implementation?

            Perfect for publishers who want higher engagement while keeping a clean, editorial-first experience.
            """
        )
    }

    static func finance() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Sentiment-Based Comments",
            description: """
            This implementation adds sentiment labels (Bullish, Neutral, Bearish) to comments, helping users quickly understand the overall tone of the discussion.

            By summarizing sentiment before entering the full conversation, readers can grasp market perspectives at a glance and decide how deeply they want to engage.

            This model works especially well for financial content where insight, clarity, and trend awareness add direct value to the reading experience.
            """
        )
    }

    static func recipes() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Rating Summary + Star Reviews",
            description: """
            This implementation combines star ratings with written comments and a summarized rating overview, turning the conversation into a source of practical feedback.

            Users can quickly evaluate how others experienced the recipe before reading individual reviews or contributing their own.

            It is particularly effective for lifestyle content where social proof and shared experiences help users make confident decisions.
            """
        )
    }

    static func sport() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Partial screen implementation",
            description: """
            This implementation places the conversation directly alongside the content - in this example, \
            live match data, removing any friction between content consumption and participation.

            Users can react and comment in real time while following the game, creating a fast-paced and highly engaging second-screen experience.

            This setup is best suited for live events where immediacy and momentum are key drivers of engagement.
            """
        )
    }

    static func video() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Bottom Sheet Overlay",
            description: """
            This implementation opens the full conversation in a bottom-sheet overlay triggered by a floating comment icon, allowing users to engage without leaving the video.

            The experience mirrors modern social video platforms, keeping users immersed while making participation easily accessible.

            It is ideal for video-first products that want to increase interaction without impacting watch time or content flow.
            """
        )
    }

    static func sideRail() -> ImplementationInfo {
        ImplementationInfo(
            subtitle: "Side Rail Panel",
            description: """
            This implementation separates content and conversation into a side rail, enabling users to read and engage simultaneously without cluttering the main article view.

            The conversation is revealed only when the user chooses to open it, giving full control over the reading experience.

            This approach works well for long-form or premium content where thoughtful discussion should complement, not disrupt, consumption.
            """
        )
    }
}
