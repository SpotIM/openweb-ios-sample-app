//
//  VideoScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK

struct VideoScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VideoScreenViewModel()
    @State private var currentIndex: Int? = 0

    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.videoURLs.enumerated()), id: \.offset) { index, url in
                    // MARK: OpenWeb SDK
                    OpenWebConversationCount(postId: viewModel.article.postId) { counter in
                        VideoPlayerPage(
                            url: url,
                            isActive: index == (currentIndex ?? 0),
                            commentsCount: counter.commentsNumber,
                            onCommentTap: viewModel.showConversation,
                            onInfoTap: viewModel.showInfo
                        )
                        .containerRelativeFrame(.vertical)
                        .id(index)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $currentIndex)
        .ignoresSafeArea()
        .background(.black)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear { viewModel.initialize() }
        .sheet(isPresented: $viewModel.isConversationVisible) {
            // MARK: OpenWeb SDK
            OpenWebConversation(
                postId: viewModel.article.postId,
                article: viewModel.articleSettings
            )
            .additionalSettings(viewModel.screenSettings)
        }
        .overlay {
            if viewModel.isInfoVisible {
                SDKUsageInfoOverlay(
                    info: viewModel.sdkUsageInfo,
                    iconColor: viewModel.color,
                    onDismiss: viewModel.hideInfo
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        VideoScreen()
    }
}
