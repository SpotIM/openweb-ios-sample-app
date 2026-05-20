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
    @State private var showPulse = true

    var body: some View {
        ScrollView {
            if let content = viewModel.article.content {
                ArticleTopSection(title: viewModel.article.title, content: content)
            }
            sideRailBody
            SDKUsageInfoCard(
                info: viewModel.sdkUsageInfo,
                iconColor: viewModel.color
            )
        }
        .background(Color(.systemGroupedBackground))
        .verticalToolbar(
            title: viewModel.title,
            color: viewModel.color
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    // MARK: OpenWeb SDK
                    OpenWebConversation(
                        postId: viewModel.article.postId,
                        article: viewModel.articleSettings
                    )
                    .additionalSettings(viewModel.screenSettings)
                } label: {
                    Image(systemName: "bubble.right")
                        .pulseHighlight(isOn: $showPulse)
                        .onDisappear { showPulse = false }
                }
            }
        }
        .onAppear { viewModel.initialize() }
    }
}

private extension SideRailScreen {
    private static let headerPrefix = "### "

    private struct Metrics {
        static let headerTopPadding: CGFloat = 24
        static let headerBottomPadding: CGFloat = 12
        static let textOpacity: Double = 0.9
        static let lineSpacing: CGFloat = 4
        static let horizontalPadding: CGFloat = 16
        static let topPadding: CGFloat = 8
    }

    var sideRailBody: some View {
        let paragraphs = ShowcaseVertical.loadArticle(named: "siderail")
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                if paragraph.hasPrefix(Self.headerPrefix) {
                    Text(String(paragraph.dropFirst(Self.headerPrefix.count)))
                        .font(.heading)
                        .padding(.top, Metrics.headerTopPadding)
                        .padding(.bottom, Metrics.headerBottomPadding)
                } else {
                    Text(paragraph)
                        .font(.bodyText)
                        .foregroundStyle(.primary.opacity(Metrics.textOpacity))
                        .lineSpacing(Metrics.lineSpacing)
                }
            }
        }
        .padding(.horizontal, Metrics.horizontalPadding)
        .padding(.top, Metrics.topPadding)
    }
}

#Preview {
    NavigationStack {
        SideRailScreen()
    }
}
