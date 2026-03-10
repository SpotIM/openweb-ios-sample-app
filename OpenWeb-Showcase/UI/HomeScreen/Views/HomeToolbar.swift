//
//  HomeToolbar.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct HomeToolbar: View {
    private struct Metrics {
        static let logoSize: CGFloat = 40
        static let infoIconSize: CGFloat = 18
        static let textSpacing: CGFloat = 2
        static let textHorizontalPadding: CGFloat = 12
        static let contentHorizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
    }

    var onAboutClick: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Image(.openwebLogo)
                .squareFrame(size: Metrics.logoSize)
            VStack(alignment: .leading, spacing: Metrics.textSpacing) {
                Text(.homeScreenTitle)
                    .font(.toolbarTitle)
                    .lineLimit(1)
                Text(.homeScreenDescription)
                    .font(.toolbarDescription)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, Metrics.textHorizontalPadding)
            Spacer()
            Button(action: onAboutClick) {
                Image(systemName: "info.circle")
                    .font(.system(size: Metrics.infoIconSize))
            }
        }
        .padding(.horizontal, Metrics.contentHorizontalPadding)
        .padding(.vertical, Metrics.verticalPadding)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview {
    HomeToolbar(onAboutClick: {})
}
