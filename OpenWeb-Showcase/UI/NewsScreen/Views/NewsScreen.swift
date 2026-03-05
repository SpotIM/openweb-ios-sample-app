//
//  NewsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct NewsScreen: View {
    @State private var viewModel = NewsScreenViewModel()

    var body: some View {
        ScrollView {
            ArticleContent(article: viewModel.article)
            ImplementationInfoCard(
                info: viewModel.implementationInfo,
                iconColor: VerticalCard.news.color
            )
        }
        .verticalToolbar(
            title: VerticalCard.news.title,
            color: VerticalCard.news.color,
            onSettingsClick: {}
        )
    }
}

#Preview {
    NavigationStack {
        NewsScreen()
    }
}
