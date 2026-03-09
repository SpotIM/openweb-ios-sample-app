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
            SDKUsageInfoCard(
                info: viewModel.implementationInfo,
                iconColor: VerticalCardData.news.color
            )
            OpenWebPreConversation(
                postId: viewModel.article.postId,
                article: viewModel.conversationArticle
            )
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: VerticalCardData.news.title,
            color: VerticalCardData.news.color,
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
