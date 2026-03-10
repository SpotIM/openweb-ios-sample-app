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
    }

    var article: ArticleData

    var body: some View {
        VStack(alignment: .leading, spacing: Metrics.titleBottomSpacing) {
            Text(article.title)
                .font(.articleTitle)
            Text(article.body.markdown())
                .font(.bodyText)
                .foregroundStyle(.secondary)
        }
        .padding(Metrics.contentPadding)
    }
}

#Preview {
    ScrollView {
        ArticleContent(article: SampleVertical.news.article)
    }
}
