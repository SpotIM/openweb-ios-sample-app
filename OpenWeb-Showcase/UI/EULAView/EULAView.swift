//
//  EULAView.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 26/04/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct EULAView: View {
    private struct Metrics {
        static let iconSize: CGFloat = 72
        static let iconCornerRadius: CGFloat = 20
        static let iconSymbolSize: CGFloat = 32
        static let headerHorizontalPadding: CGFloat = 24
        static let headerTopPadding: CGFloat = 20
        static let headerBottomPadding: CGFloat = 12
        static let titleTopSpacing: CGFloat = 16
        static let subtitleTopSpacing: CGFloat = 4
        static let contentHorizontalPadding: CGFloat = 16
        static let cardCornerRadius: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let checkboxSize: CGFloat = 22
        static let checkboxBorderWidth: CGFloat = 2
        static let checkboxLabelSpacing: CGFloat = 12
        static let checkboxCardTopSpacing: CGFloat = 12
        static let actionHorizontalPadding: CGFloat = 16
        static let actionTopPadding: CGFloat = 16
        static let actionBottomPadding: CGFloat = 24
        static let buttonHeight: CGFloat = 50
        static let buttonCornerRadius: CGFloat = 16
        static let footnoteTopSpacing: CGFloat = 12
        static let iconGradientTop = Color(red: 0.1, green: 0.535, blue: 1.0)
        static let iconGradientBottom = Color(red: 0, green: 0.435, blue: 0.9)
    }

    var onAccept: () -> Void

    @State private var isAgreed = false
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentSection
            actionSection
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
        .presentationDetents([.height(contentHeight)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews

private extension EULAView {
    var headerSection: some View {
        VStack(spacing: 0) {
            iconView
            Text(.eulaTitle)
                .font(.eulaTitle)
                .padding(.top, Metrics.titleTopSpacing)
            Text(.eulaSubtitle)
                .font(.eulaSubtitle)
                .foregroundStyle(.secondary)
                .padding(.top, Metrics.subtitleTopSpacing)
        }
        .padding(.horizontal, Metrics.headerHorizontalPadding)
        .padding(.top, Metrics.headerTopPadding)
        .padding(.bottom, Metrics.headerBottomPadding)
    }

    var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Metrics.iconCornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Metrics.iconGradientTop, Metrics.iconGradientBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .squareFrame(size: Metrics.iconSize)
                .shadow(color: Metrics.iconGradientTop.opacity(0.3), radius: 8, y: 4)
            Image(systemName: "checkmark.shield")
                .font(.system(size: Metrics.iconSymbolSize, weight: .regular))
                .foregroundStyle(.white)
        }
    }

    var contentSection: some View {
        VStack(spacing: 0) {
            bodyTextCard
            checkboxCard
                .padding(.top, Metrics.checkboxCardTopSpacing)
        }
        .padding(.horizontal, Metrics.contentHorizontalPadding)
    }

    var bodyTextCard: some View {
        Text(String(localized: "eulaBodyText").markdown())
            .font(.eulaBody)
            .foregroundStyle(Color.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.cardPadding)
            .roundedRect(cornerRadius: Metrics.cardCornerRadius, background: Color(uiColor: .systemBackground))
            .tint(.blue)
    }

    var checkboxCard: some View {
        Button(action: { isAgreed.toggle() }) {
            HStack(spacing: Metrics.checkboxLabelSpacing) {
                checkboxIcon
                Text(.eulaCheckboxLabel)
                    .font(.eulaBody)
                    .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.cardPadding)
            .roundedRect(cornerRadius: Metrics.cardCornerRadius, background: Color(uiColor: .systemBackground))
        }
        .buttonStyle(.plain)
    }

    var checkboxIcon: some View {
        Group {
            if isAgreed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: Metrics.checkboxSize))
            } else {
                Circle()
                    .strokeBorder(Color(uiColor: .systemGray3), lineWidth: Metrics.checkboxBorderWidth)
                    .squareFrame(size: Metrics.checkboxSize)
            }
        }
        .squareFrame(size: Metrics.checkboxSize)
    }

    var actionSection: some View {
        VStack(spacing: 0) {
            continueButton
            Text(.eulaFootnote)
                .font(.eulaFootnote)
                .foregroundStyle(.secondary)
                .padding(.top, Metrics.footnoteTopSpacing)
        }
        .padding(.horizontal, Metrics.actionHorizontalPadding)
        .padding(.top, Metrics.actionTopPadding)
        .padding(.bottom, Metrics.actionBottomPadding)
    }

    var continueButton: some View {
        Button(action: onAccept) {
            Text(.eulaContinueButton)
                .font(.eulaButton)
                .frame(maxWidth: .infinity)
                .frame(height: Metrics.buttonHeight)
                .foregroundStyle(isAgreed ? .white : Color(white: 0.55))
                .roundedRect(
                    cornerRadius: Metrics.buttonCornerRadius,
                    background: isAgreed ? .blue : Color(uiColor: .systemGray4)
                )
        }
        .disabled(!isAgreed)
    }
}

#Preview {
    Color.gray.opacity(0.3)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            EULAView(onAccept: {})
        }
}
