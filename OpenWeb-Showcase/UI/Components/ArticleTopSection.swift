//
//  ArticleTopSection.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ArticleTopSection: View {
    private struct Metrics {
        static let contentPadding: CGFloat = 16
        static let topPadding: CGFloat = 16
        static let metaSpacing: CGFloat = 8
        static let titleSpacing: CGFloat = 8
        static let clockIconSpacing: CGFloat = 3
        static let authorRowSpacing: CGFloat = 12
        static let authorRowVerticalPadding: CGFloat = 12
        static let authorRowBottomMargin: CGFloat = 12
        static let authorTextSpacing: CGFloat = 2
        static let dividerTopPadding: CGFloat = 4
        static let avatarSize: CGFloat = 36
        // swiftlint:disable:next no_magic_numbers
        static let imageAspectRatio: CGFloat = 16.0 / 9.0
        static let sourceTracking: CGFloat = 0.5
        static let titleLineSpacing: CGFloat = 2
        static let leadLineSpacing: CGFloat = 4
    }

    var title: String
    var content: ArticleContent

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerImage
            VStack(alignment: .leading, spacing: Metrics.titleSpacing) {
                metaRow
                titleSection
                authorRow
                leadSection
            }
            .padding(.horizontal, Metrics.contentPadding)
            .padding(.top, Metrics.topPadding)
        }
    }
}

private extension ArticleTopSection {
    var headerImage: some View {
        AsyncImage(url: URL(string: content.imageURL)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color(.systemGray5)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(Metrics.imageAspectRatio, contentMode: .fill)
        .clipped()
    }

    var metaRow: some View {
        HStack(spacing: Metrics.metaSpacing) {
            Text(content.sourceName.uppercased())
                .font(.articleSourceLabel)
                .tracking(Metrics.sourceTracking)
                .foregroundStyle(.primary)
            Text("·")
            HStack(spacing: Metrics.clockIconSpacing) {
                Image(systemName: "clock")
                Text(content.readTime)
            }
            .font(.smallLabel)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    var titleSection: some View {
        Text(title)
            .font(.screenTitle)
            .lineSpacing(Metrics.titleLineSpacing)
        Text(content.subtitle)
            .font(.articleSubtitle)
            .foregroundStyle(.secondary)
            .lineSpacing(Metrics.titleLineSpacing)
    }

    var authorRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.top, Metrics.dividerTopPadding)
            HStack(spacing: Metrics.authorRowSpacing) {
                Text(content.authorInitials)
                    .font(.articleSourceLabel)
                    .foregroundStyle(.secondary)
                    .squareFrame(size: Metrics.avatarSize)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: Metrics.authorTextSpacing) {
                    Text(content.authorName)
                        .font(.articleAuthorName)
                    Text(content.date)
                        .font(.smallLabel)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, Metrics.authorRowVerticalPadding)
            Divider()
        }
        .padding(.bottom, Metrics.authorRowBottomMargin)
    }

    @ViewBuilder
    var leadSection: some View {
        if !content.leadParagraph.isEmpty {
            Text(content.leadParagraph)
                .font(.articleAuthorName)
                .foregroundStyle(.secondary)
                .lineSpacing(Metrics.leadLineSpacing)
        }
    }
}

#Preview {
    ScrollView {
        ArticleTopSection(
            title: ShowcaseVertical.news.article.title,
            content: ShowcaseVertical.news.article.content!
        )
    }
}
