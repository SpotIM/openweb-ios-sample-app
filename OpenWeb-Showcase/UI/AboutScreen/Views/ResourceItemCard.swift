//
//  ResourceItemCard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
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
                HStack(spacing: Metrics.iconTextSpacing) {
                    Image(item.icon)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.primary)
                        .frame(width: Metrics.iconSize, height: Metrics.iconSize)

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
                .padding(.trailing, Metrics.trailingSpacing)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: Metrics.chevronSize))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: Metrics.chevronSize, height: Metrics.chevronSize)
            }
            .padding(Metrics.contentPadding)
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .stroke(Color(uiColor: .separator), lineWidth: Metrics.borderWidth)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ResourceItemCard(
        item: ResourceItem(
            title: "SDK Documentation",
            icon: "ic_info",
            url: URL(string: "https://developers.openweb.com")
        )
    )
    .padding()
}
