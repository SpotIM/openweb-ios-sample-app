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
        static let borderWidth: CGFloat = 1
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
            if let url = item.url {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 0) {
                leadingContent
                    .padding(.trailing, Metrics.trailingSpacing)
                Spacer()
                chevronView
            }
            .padding(Metrics.contentPadding)
            .overlay { cardBorder }
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
            .resizable()
            .scaledToFit()
            .foregroundStyle(.primary)
            .frame(width: Metrics.iconSize, height: Metrics.iconSize)
    }

    var textContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            if let description = item.description {
                Spacer().frame(height: Metrics.descriptionTopSpacing)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: Metrics.chevronSize))
            .foregroundStyle(Color.accentColor)
            .frame(width: Metrics.chevronSize, height: Metrics.chevronSize)
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
            .stroke(Color(uiColor: .separator), lineWidth: Metrics.borderWidth)
    }
}

#Preview {
    ResourceItemCard(item: .sdkDocs)
        .padding()
}
