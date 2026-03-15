//
//  VideoActionButtons.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// MARK: - Metrics

private struct Metrics {
    static let columnSpacing: CGFloat = 28
    static let iconLabelSpacing: CGFloat = 16
    static let iconSize: CGFloat = 26
    static let iconBackgroundSize: CGFloat = 46
    static let iconBackgroundOpacity: CGFloat = 0.15
    static let trailingPadding: CGFloat = 20
    static let pressedScale: CGFloat = 0.85
    static let springResponse: Double = 0.3
    static let springDamping: Double = 0.4
    // Shadows
    static let shadowStrongOpacity: CGFloat = 0.6
    static let shadowRadius: CGFloat = 3
    static let shadowYOffset: CGFloat = 1
}

// MARK: - VideoActionButtons

struct VideoActionButtons: View {
    var onInfoTap: () -> Void = {}

    var body: some View {
        VStack(spacing: Metrics.columnSpacing) {
            ActionButton(icon: "heart", label: .videoLikesCount)
            ActionButton(icon: "message", label: .videoCommentCount, tint: Color(.video))
            ActionButton(icon: "square.and.arrow.up", label: .videoShareLabel)
            ActionButton(icon: "chevron.left.forwardslash.chevron.right", label: .videoInfoLabel, tint: Color(.video), action: onInfoTap)
        }
        .padding(.trailing, Metrics.trailingPadding)
    }
}

// MARK: - ActionButton

private struct ActionButton: View {
    var icon: String
    var label: LocalizedStringResource
    var tint: Color = .white
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: Metrics.iconLabelSpacing) {
                Image(systemName: icon)
                    .foregroundStyle(tint)
                    .shadow(color: .black.opacity(Metrics.shadowStrongOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowYOffset)
                    .squareFrame(size: Metrics.iconSize)
                    .background(
                        Circle()
                            .fill(.black.opacity(Metrics.iconBackgroundOpacity))
                            .frame(width: Metrics.iconBackgroundSize, height: Metrics.iconBackgroundSize)
                    )
                Text(label)
                    .font(.videoLabel)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(Metrics.shadowStrongOpacity), radius: Metrics.shadowRadius, x: 0, y: Metrics.shadowYOffset)
            }
        }
        .buttonStyle(SpringButtonStyle())
    }
}

// MARK: - SpringButtonStyle

private struct SpringButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? Metrics.pressedScale : 1)
            .animation(
                .spring(response: Metrics.springResponse, dampingFraction: Metrics.springDamping),
                value: configuration.isPressed
            )
    }
}
