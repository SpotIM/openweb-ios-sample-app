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
    @StateObject private var viewModel = NewsScreenViewModel()

    var body: some View {
        ScrollView {
            if let content = viewModel.article.content {
                ArticleTopSection(title: viewModel.article.title, content: content)
            }
            ArticleBodyText(text: ShowcaseVertical.loadArticle(named: "news"))
            SDKUsageInfoCard(
                info: viewModel.sdkUsageInfo,
                iconColor: viewModel.color
            )
            // MARK: OpenWeb SDK
            OpenWebPreConversation(
                postId: viewModel.article.postId,
                article: viewModel.articleSettings
            )
            .additionalSettings(viewModel.screenSettings)
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color
        )
        .onAppear { viewModel.initialize() }
    }
}

#Preview {
    NavigationStack {
        NewsScreen()
    }
}
