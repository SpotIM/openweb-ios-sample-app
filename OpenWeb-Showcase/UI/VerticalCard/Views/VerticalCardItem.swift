//
//  VerticalCardItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalCardItem: View {
    private struct Metrics {
        static let cardHeight: CGFloat = 180
        static let cardCornerRadius: CGFloat = 16
        static let cardElevation: CGFloat = 2
        static let paddingLarge: CGFloat = 16
        static let paddingMedium: CGFloat = 12
        static let iconContainerSize: CGFloat = 56
        static let iconContainerCornerRadius: CGFloat = 12
        static let cardDescriptionLineSpacing: CGFloat = 5
        static let iconBackgroundOpacity: CGFloat = 0.15
        static let borderOpacity: CGFloat = 0.08
        static let borderWidth: CGFloat = 1
        static let shadowOpacity: CGFloat = 0.12
        static let shadowY: CGFloat = 2
        static let titleDescriptionSpacing: CGFloat = 4
    }

    var vertical: VerticalCard
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            cardContent
                .padding(Metrics.paddingLarge)
                .frame(maxWidth: .infinity, minHeight: Metrics.cardHeight, maxHeight: Metrics.cardHeight)
                .background { cardBackground }
                .shadow(color: Color.black.opacity(Metrics.shadowOpacity), radius: Metrics.cardElevation, x: 0, y: Metrics.shadowY)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

private extension VerticalCardItem {
    var cardContent: some View {
        VStack(alignment: .center, spacing: 0) {
            iconView
            Spacer().frame(height: Metrics.paddingMedium)
            titleView
            Spacer().frame(height: Metrics.titleDescriptionSpacing)
            descriptionView
        }
    }

    var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Metrics.iconContainerCornerRadius, style: .continuous)
                .fill(vertical.color.opacity(Metrics.iconBackgroundOpacity))
                .frame(width: Metrics.iconContainerSize, height: Metrics.iconContainerSize)
            Text(vertical.icon)
                .font(.cardIcon)
        }
    }

    var titleView: some View {
        Text(vertical.title)
            .font(.cardTitle)
            .foregroundStyle(.primary)
            .lineLimit(1)
            .truncationMode(.tail)
            .multilineTextAlignment(.center)
    }

    var descriptionView: some View {
        Text(vertical.description)
            .font(.cardDescription)
            .foregroundStyle(.secondary)
            .lineLimit(2)
            .truncationMode(.tail)
            .multilineTextAlignment(.center)
            .lineSpacing(Metrics.cardDescriptionLineSpacing)
    }

    var cardBackground: some View {
        RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
            .fill(Color(uiColor: .systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
                    .stroke(Color.black.opacity(Metrics.borderOpacity), lineWidth: Metrics.borderWidth)
            }
    }
}

#Preview {
    VerticalCardItem(
        vertical: VerticalCard(
            id: "news",
            icon: "🌍",
            title: "News",
            description: "A short description that can wrap to two lines.",
            color: .blue
        ),
        onClick: {}
    )
    .padding()
}
