//
//  VideoScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VideoScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = VideoScreenViewModel()
    @State private var currentIndex = 0

    var body: some View {
        VerticalPager(pageCount: viewModel.videoURLs.count, currentIndex: $currentIndex) {
            ForEach(Array(viewModel.videoURLs.enumerated()), id: \.offset) { index, url in
                VideoPlayerPage(url: url, isActive: index == currentIndex, onInfoTap: viewModel.showInfo)
            }
        }
        .ignoresSafeArea()
        .background(.black)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
        .onAppear { viewModel.initialize() }
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
