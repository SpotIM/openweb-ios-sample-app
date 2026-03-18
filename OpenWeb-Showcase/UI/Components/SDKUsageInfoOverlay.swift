//
//  SDKUsageInfoOverlay.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// MARK: - SDKUsageInfoOverlay

struct SDKUsageInfoOverlay: View {
    // MARK: - Metrics
    private struct Metrics {
        static let backgroundOpacity: CGFloat = 0.7
        static let cardHorizontalPadding: CGFloat = 16
        static let cardBottomPadding: CGFloat = 140
        static let cardInnerPadding: CGFloat = 20
        static let cardCornerRadius: CGFloat = 12
        static let headerSpacing: CGFloat = 8
        static let closeButtonSize: CGFloat = 32
        static let closeButtonBackgroundOpacity: CGFloat = 0.1
        static let subtitleTopSpacing: CGFloat = 12
        static let descriptionTopSpacing: CGFloat = 8
        static let descriptionOpacity: CGFloat = 0.8
        // swiftlint:disable no_magic_numbers
        static let cardBackground = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    }

    var info: SDKUsageInfo
    var iconColor: Color
    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(Metrics.backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(alignment: .leading, spacing: 0) {
                headerRow
                Text(info.subtitle)
                    .font(.infoOverlaySubtitle)
                    .foregroundStyle(.white)
                    .padding(.top, Metrics.subtitleTopSpacing)
                Text(info.description)
                    .font(.bodyText)
                    .foregroundStyle(.white.opacity(Metrics.descriptionOpacity))
                    .padding(.top, Metrics.descriptionTopSpacing)
            }
            .padding(Metrics.cardInnerPadding)
            .roundedRect(cornerRadius: Metrics.cardCornerRadius, background: Metrics.cardBackground)
            .padding(.horizontal, Metrics.cardHorizontalPadding)
            .padding(.bottom, Metrics.cardBottomPadding)
        }
    }
}

// MARK: - Subviews

private extension SDKUsageInfoOverlay {
    var headerRow: some View {
        HStack(alignment: .top) {
            HStack(spacing: Metrics.headerSpacing) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.infoOverlayIcon)
                    .foregroundStyle(iconColor)
                Text(info.title)
                    .font(.heading)
                    .foregroundStyle(.white)
            }
            Spacer()
            closeButton
        }
    }

    var closeButton: some View {
        Button(action: onDismiss) {
            Image(systemName: "xmark")
                .font(.infoOverlayCloseIcon)
                .foregroundStyle(.white)
                .squareFrame(size: Metrics.closeButtonSize)
                .background(Circle().fill(.white.opacity(Metrics.closeButtonBackgroundOpacity)))
        }
    }
}
