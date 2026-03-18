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
        VStack {
            SportScoreboard(
                homeScore: viewModel.homeScore,
                awayScore: viewModel.awayScore,
                matchMinute: viewModel.matchMinute,
                isLive: viewModel.isLive,
                goalEvent: viewModel.goalEvent
            )
            SDKUsageInfoCard(
                info: viewModel.sdkUsageInfo,
                iconColor: viewModel.color
            )
            // MARK: OpenWeb SDK
            OpenWebConversation(
                postId: viewModel.article.postId,
                article: viewModel.articleSettings
            )
                .headerStyle(.none)
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
        SportScreen()
    }
}
