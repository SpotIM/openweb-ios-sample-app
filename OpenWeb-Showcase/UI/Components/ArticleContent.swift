//
//  ArticleContent.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ArticleContent: View {
    private struct Metrics {
        static let contentPadding: CGFloat = 16
        static let titleBottomSpacing: CGFloat = 16
        static let paragraphSpacing: CGFloat = 12
    }

    var article: ArticleData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(article.title)
                .font(.articleTitle)
                .foregroundStyle(.primary)
            Spacer().frame(height: Metrics.titleBottomSpacing)
            ForEach(Array(article.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(markdown(paragraph))
                    .font(.bodyText)
                    .foregroundStyle(.secondary)
                Spacer().frame(height: Metrics.paragraphSpacing)
            }
        }
        .padding(Metrics.contentPadding)
    }
}

// MARK: - Private

private extension ArticleContent {
    func markdown(_ text: String) -> AttributedString {
        (try? AttributedString(markdown: text)) ?? AttributedString(text)
    }
}

#Preview {
    ScrollView {
        ArticleContent(article: MockArticles.news())
    }
}
