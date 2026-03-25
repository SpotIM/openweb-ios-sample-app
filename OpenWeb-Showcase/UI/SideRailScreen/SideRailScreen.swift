//
//  SideRailScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 11/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct SideRailScreen: View {
    @StateObject private var viewModel = SideRailScreenViewModel()
    @State private var bubbleTapped = false

    var body: some View {
        ScrollView {
            ArticleContent(article: viewModel.article)
            SDKUsageInfoCard(
                info: viewModel.sdkUsageInfo,
                iconColor: viewModel.color
            )
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color,
            onSettingsClick: {}
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    // MARK: OpenWeb SDK
                    OpenWebConversation(postId: viewModel.article.postId)
                } label: {
                    Image(systemName: "bubble.right")
                        .pulseHighlight(tapped: $bubbleTapped)
                        .onDisappear { bubbleTapped = true }
                }
            }
        }
        .onAppear { viewModel.initialize() }
    }
}

#Preview {
    NavigationStack {
        SideRailScreen()
    }
}
