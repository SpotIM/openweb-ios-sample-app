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
    @State private var viewModel = SideRailScreenViewModel()

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
        .onAppear { viewModel.initialize() }
    }
}

#Preview {
    NavigationStack {
        SideRailScreen()
    }
}
