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
        static let cornerRadius: CGFloat = 12
        static let borderOpacity: CGFloat = 0.15
    }

    var info: SDKUsageInfo
    var iconColor: Color

    var body: some View {
        DisclosureGroup {
            Text(info.description)
                .font(.bodyText)
                .foregroundStyle(.secondary)
        } label: {
            HStack {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: Metrics.iconSize))
                    .foregroundStyle(iconColor)
                VStack(alignment: .leading, spacing: Metrics.subtitleTopSpacing) {
                    Text(info.title)
                        .font(.bodyText)
                        .foregroundStyle(.primary)
                    Text(info.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, Metrics.iconTextSpacing)
            }
        }
        .tint(.primary)
        .padding(Metrics.contentPadding)
        .roundedRect(
            cornerRadius: Metrics.cornerRadius,
            border: Color.black.opacity(Metrics.borderOpacity)
        )
        .padding(.horizontal, Metrics.cardPadding)
    }
}

#Preview("Custom (current)") {
    SDKUsageInfoCard(
        info: MockSDKUsageInfo.news(),
        iconColor: Color(.news)
    )
}
