//
//  ReactionsCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 20/07/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct ReactionsCard: View {
    private struct Metrics {
        static let cardPadding: CGFloat = 16
        static let contentPadding: CGFloat = 16
        static let iconSize: CGFloat = 16
        static let iconTextSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let borderOpacity: CGFloat = 0.15
    }

    var postId: OWPostId
    var themeName: String
    var iconColor: Color
    @State private var isExpanded = true
    @State private var settingsVersion = 0
    @State private var hasAppeared = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            // MARK: OpenWeb SDK
            OpenWebReactions(postId: postId, themeName: themeName)
        } label: {
            HStack {
                Image(systemName: "heart")
                    .font(.system(size: Metrics.iconSize))
                    .foregroundStyle(iconColor)
                Text("Reactions")
                    .font(.bodyText)
                    .foregroundStyle(.primary)
                    .padding(.leading, Metrics.iconTextSpacing)
            }
        }
        .id(settingsVersion)
        .tint(.primary)
        .padding(Metrics.contentPadding)
        .roundedRect(
            cornerRadius: Metrics.cornerRadius,
            background: Color(uiColor: .systemBackground),
            border: Color.black.opacity(Metrics.borderOpacity)
        )
        .padding(.horizontal, Metrics.cardPadding)
        .onAppear {
            // On reappear, force the SDK widget to reinitialize so it picks up
            // any customization changes (theme, fonts, colors) applied while away.
            guard hasAppeared else {
                hasAppeared = true
                return
            }
            settingsVersion += 1
        }
    }
}

#Preview {
    ReactionsCard(postId: ShowcaseVertical.news.article.postId, themeName: ShowcaseVertical.news.article.title, iconColor: ShowcaseVertical.news.color)
}
