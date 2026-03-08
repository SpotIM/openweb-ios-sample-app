//
//  VerticalCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalCard: View {
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
        static let shadowOpacity: CGFloat = 0.12
        static let shadowY: CGFloat = 2
        static let titleDescriptionSpacing: CGFloat = 4
    }

    var vertical: VerticalCardData
    var onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            cardContent
                .padding(Metrics.paddingLarge)
                .frame(maxWidth: .infinity, minHeight: Metrics.cardHeight, maxHeight: Metrics.cardHeight)
                .roundedRectBackground(cornerRadius: Metrics.cardCornerRadius)
                .roundedRectBorder(
                    cornerRadius: Metrics.cardCornerRadius,
                    color: Color.black.opacity(Metrics.borderOpacity)
                )
                .shadow(color: Color.black.opacity(Metrics.shadowOpacity), radius: Metrics.cardElevation, x: 0, y: Metrics.shadowY)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

private extension VerticalCard {
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
        Text(vertical.icon)
            .font(.cardIcon)
            .frame(width: Metrics.iconContainerSize, height: Metrics.iconContainerSize)
            .roundedRectBackground(
                cornerRadius: Metrics.iconContainerCornerRadius,
                color: vertical.color.opacity(Metrics.iconBackgroundOpacity)
            )
    }

    var titleView: some View {
        Text(vertical.title)
            .font(.cardTitle)
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

}

#Preview {
    VerticalCard(vertical: .news, onClick: {})
        .padding()
}
