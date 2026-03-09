//
//  SDKUsageInfoCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SDKUsageInfoCard: View {
    private struct Metrics {
        static let cardPadding: CGFloat = 16
        static let contentPadding: CGFloat = 16
        static let iconSize: CGFloat = 16
        static let iconTextSpacing: CGFloat = 12
        static let subtitleTopSpacing: CGFloat = 2
        static let descriptionTopSpacing: CGFloat = 12
        static let cornerRadius: CGFloat = 12
        static let borderOpacity: CGFloat = 0.15
    }

    var info: SDKUsageInfo
    var iconColor: Color
    @State private var expanded = false

    var body: some View {
        cardContent
            .padding(Metrics.contentPadding)
            .roundedRectBackground(cornerRadius: Metrics.cornerRadius)
            .roundedRectBorder(
                cornerRadius: Metrics.cornerRadius,
                color: Color.black.opacity(Metrics.borderOpacity)
            )
            .padding(.horizontal, Metrics.cardPadding)
            .onTapGesture { withAnimation { expanded.toggle() } }
    }
}

// MARK: - Subviews

private extension SDKUsageInfoCard {
    var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if expanded {
                Spacer().frame(height: Metrics.descriptionTopSpacing)
                descriptionView
            }
        }
    }

    var headerRow: some View {
        HStack(alignment: .center) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: Metrics.iconSize))
                .foregroundStyle(iconColor)
            VStack(alignment: .leading, spacing: Metrics.subtitleTopSpacing) {
                Text(info.title)
                    .font(.bodyText)
                Text(info.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, Metrics.iconTextSpacing)
            Spacer()
            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                .font(.system(size: Metrics.iconSize))
        }
    }

    var descriptionView: some View {
        Text(info.description)
            .font(.bodyText)
            .foregroundStyle(.secondary)
    }
}

#Preview {
    SDKUsageInfoCard(
        info: MockSDKUsageInfo.news(),
        iconColor: Color(.news)
    )
}
