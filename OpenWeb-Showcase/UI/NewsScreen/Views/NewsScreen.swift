//
//  NewsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct NewsScreen: View {
    @State private var viewModel = NewsScreenViewModel()

    var body: some View {
        ScrollView {
            ArticleContent(article: viewModel.article)
            ImplementationInfoCard(
                info: viewModel.implementationInfo,
                iconColor: VerticalCard.news.color
            )
            OpenWebPreConversation(
                postId: viewModel.article.conversationIds.postId,
                article: viewModel.conversationArticle
            )
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: VerticalCard.news.title,
            color: VerticalCard.news.color,
            onSettingsClick: {}
        )
        .onAppear { viewModel.initialize() }
    }
}

#Preview {
    NavigationStack {
        NewsScreen()
    }
}
