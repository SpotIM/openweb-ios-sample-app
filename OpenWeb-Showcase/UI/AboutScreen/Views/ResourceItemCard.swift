//
//  ResourceItemCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ResourceItemCard: View {
    private struct Metrics {
        static let cornerRadius: CGFloat = 12
        static let contentPadding: CGFloat = 16
        static let iconSize: CGFloat = 24
        static let iconTextSpacing: CGFloat = 12
        static let chevronSize: CGFloat = 20
        static let descriptionTopSpacing: CGFloat = 4
        static let trailingSpacing: CGFloat = 12
    }

    var item: ResourceItem

    var body: some View {
        Button {
            UIApplication.shared.open(item.url)
        } label: {
            HStack(spacing: 0) {
                leadingContent
                    .padding(.trailing, Metrics.trailingSpacing)
                Spacer()
                chevronView
            }
            .padding(Metrics.contentPadding)
            .roundedRect(
                cornerRadius: Metrics.cornerRadius,
                background: nil,
                border: Color(uiColor: .separator)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

private extension ResourceItemCard {
    var leadingContent: some View {
        HStack(spacing: Metrics.iconTextSpacing) {
            iconView
            textContent
        }
    }

    var iconView: some View {
        Image(item.icon)
            .squareFrame(size: Metrics.iconSize)
    }

    var textContent: some View {
        Text(item.title)
            .font(.resourceTitle)
    }

    var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: Metrics.chevronSize))
            .foregroundStyle(Color.accentColor)
    }

}

#Preview {
    ResourceItemCard(item: .sdkDocs)
        .padding()
}
