//
//  SportScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct SportScreen: View {
    @StateObject private var viewModel = SportScreenViewModel()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                SportScoreboard(
                    homeScore: viewModel.homeScore,
                    awayScore: viewModel.awayScore,
                    matchMinute: viewModel.matchMinute,
                    isLive: viewModel.isLive,
                    goalEvent: viewModel.goalEvent
                )
                ScrollView {
                    SDKUsageInfoCard(
                        info: viewModel.sdkUsageInfo,
                        iconColor: viewModel.color
                    )
                    .padding(.top)
                    // MARK: OpenWeb SDK
                    OpenWebConversation(
                        postId: viewModel.article.postId,
                        article: viewModel.conversationArticle
                    )
                    .frame(height: geometry.size.height)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color,
            onSettingsClick: {}
        )
        .onAppear { viewModel.initialize() }
    }
}

#Preview {
    NavigationStack {
        SportScreen()
    }
}
