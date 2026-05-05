//
//  ArticleBodyText.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 15/04/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ArticleBodyText: View {
    private struct Metrics {
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 8
        static let textOpacity: Double = 0.8
        static let lineSpacing: CGFloat = 4
    }

    var text: String

    var body: some View {
        if !text.isEmpty {
            Text(text.markdown())
                .font(.bodyText)
                .foregroundStyle(.primary.opacity(Metrics.textOpacity))
                .lineSpacing(Metrics.lineSpacing)
                .padding(.horizontal, Metrics.horizontalPadding)
                .padding(.top, Metrics.topPadding)
        }
    }
}

#Preview {
    ScrollView {
        ArticleBodyText(text: ShowcaseVertical.loadArticle(named: "news"))
    }
}
