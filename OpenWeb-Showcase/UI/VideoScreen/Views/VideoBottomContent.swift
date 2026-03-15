//
//  VideoBottomContent.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// MARK: - Metrics

private struct Metrics {
    // Creator row
    static let creatorRowSpacing: CGFloat = 10
    static let creatorRowBottomPadding: CGFloat = 10
    // Follow button
    static let followHorizontalPadding: CGFloat = 12
    static let followVerticalPadding: CGFloat = 6
    static let followBackgroundOpacity: CGFloat = 0.25
    // Description
    static let descriptionBottomPadding: CGFloat = 14
    static let descriptionLineSpacing: CGFloat = 7
    // Music
    static let musicSpacing: CGFloat = 8
    // Shadows
    static let shadowStrongOpacity: CGFloat = 0.6
    static let shadowMediumOpacity: CGFloat = 0.4
    static let shadowLightOpacity: CGFloat = 0.3
    static let shadowRadius: CGFloat = 3
    static let shadowSmallRadius: CGFloat = 2
    static let shadowLargeRadius: CGFloat = 4
    static let shadowYOffset: CGFloat = 1
}

// MARK: - VideoBottomContent

struct VideoBottomContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CreatorInfoRow()
                .padding(.bottom, Metrics.creatorRowBottomPadding)
            VideoDescription()
                .padding(.bottom, Metrics.descriptionBottomPadding)
            MusicInfo()
        }
    }
}

// MARK: - Subviews

private struct CreatorInfoRow: View {
    var body: some View {
        HStack(spacing: Metrics.creatorRowSpacing) {
            Text(.videoCreatorHandle)
                .font(.videoCreatorName)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(Metrics.shadowStrongOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowYOffset)
            FollowButton()
        }
    }
}

private struct FollowButton: View {
    var body: some View {
        Text(.videoFollowLabel)
            .font(.videoLabel)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(Metrics.shadowLightOpacity), radius: Metrics.shadowSmallRadius, x: 0, y: Metrics.shadowYOffset)
            .padding(.horizontal, Metrics.followHorizontalPadding)
            .padding(.vertical, Metrics.followVerticalPadding)
            .background(.white.opacity(Metrics.followBackgroundOpacity), in: Capsule())
    }
}

private struct VideoDescription: View {
    var body: some View {
        Text(.videoDescription)
            .font(.videoDescription)
            .lineSpacing(Metrics.descriptionLineSpacing)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(Metrics.shadowStrongOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowYOffset)
    }
}

private struct MusicInfo: View {
    var body: some View {
        HStack(spacing: Metrics.musicSpacing) {
            Image(systemName: "music.note")
                .font(.caption)
                .shadow(color: .black.opacity(Metrics.shadowMediumOpacity), radius: Metrics.shadowLargeRadius)
            Text(.videoMusicInfo)
                .font(.bodyText)
                .shadow(color: .black.opacity(Metrics.shadowStrongOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowYOffset)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
    }
}
