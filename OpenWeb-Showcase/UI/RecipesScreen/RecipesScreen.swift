//
//  RecipesScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct RecipesScreen: View {
    @StateObject private var viewModel = RecipesScreenViewModel()

    var body: some View {
        ScrollView {
            if let content = viewModel.article.content {
                ArticleTopSection(title: viewModel.article.title, content: content)
            }
            recipeBody
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
            .starRatingEnabled(true)
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color
        )
        .onAppear { viewModel.initialize() }
    }
}

private extension RecipesScreen {
    private struct Metrics {
        static let bodyImageURL = "https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&q=80"
        // swiftlint:disable:next no_magic_numbers
        static let bodyImageAspectRatio: CGFloat = 4.0 / 3.0
        static let bodySpacing: CGFloat = 8
    }

    var recipeBody: some View {
        VStack(alignment: .leading, spacing: Metrics.bodySpacing) {
            ArticleBodyText(text: ShowcaseVertical.loadArticle(named: "recipes"))
            AsyncImage(url: URL(string: Metrics.bodyImageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Color(.systemGray5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(Metrics.bodyImageAspectRatio, contentMode: .fill)
            .clipped()
            ArticleBodyText(text: ShowcaseVertical.loadArticle(named: "recipes_body2"))
        }
    }
}

#Preview {
    NavigationStack {
        RecipesScreen()
    }
}
