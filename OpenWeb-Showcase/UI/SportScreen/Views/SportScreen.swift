//
//  SportScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SportScreen: View {
    @StateObject private var viewModel = SportScreenViewModel()

    var body: some View {
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
            }
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color,
            onSettingsClick: {}
        )
    }
}

#Preview {
    NavigationStack {
        SportScreen()
    }
}
