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
        static let headerTopPadding: CGFloat = 38
        static let subtitleTopSpacing: CGFloat = 4
        static let cardCornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let checkboxSize: CGFloat = 22
        static let spacing: CGFloat = 12
        static let actionBottomPadding: CGFloat = 24
        static let bodyLineSpacing: CGFloat = 3.75
        // swiftlint:disable no_magic_numbers
        static let sheetBackground = Color(white: 0.98)
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
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
        .presentationDetents([.height(contentHeight)])
        .presentationBackground(Metrics.sheetBackground)
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
                .padding(.top, Metrics.padding)
            Text(.eulaSubtitle)
                .font(.eulaSubtitle)
                .foregroundStyle(.secondary)
                .padding(.top, Metrics.subtitleTopSpacing)
        }
        .padding(.horizontal, Metrics.headerHorizontalPadding)
        .padding(.top, Metrics.headerTopPadding)
        .padding(.bottom, Metrics.spacing)
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
        VStack(spacing: Metrics.spacing) {
            bodyTextCard
            checkboxCard
        }
        .padding(.horizontal, Metrics.padding)
    }

    var bodyTextCard: some View {
        Text(String(localized: "eulaBodyText").markdown())
            .font(.eulaBody)
            .foregroundStyle(Color.primary)
            .lineSpacing(Metrics.bodyLineSpacing)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.padding)
            .roundedRect(cornerRadius: Metrics.cardCornerRadius, background: Color(uiColor: .systemBackground))
            .tint(.blue)
    }

    var checkboxCard: some View {
        Button(action: { isAgreed.toggle() }) {
            HStack(spacing: Metrics.spacing) {
                checkboxIcon
                Text(.eulaCheckboxLabel)
                    .font(.eulaBody)
                    .foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.padding)
            .roundedRect(cornerRadius: Metrics.cardCornerRadius, background: Color(uiColor: .systemBackground))
        }
        .buttonStyle(.plain)
    }

    var checkboxIcon: some View {
        Image(systemName: isAgreed ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isAgreed ? Color.blue : Color(uiColor: .systemGray3))
            .font(.system(size: Metrics.checkboxSize))
            .squareFrame(size: Metrics.checkboxSize)
    }

    var actionSection: some View {
        VStack(spacing: Metrics.spacing) {
            continueButton
            Text(.eulaFootnote)
                .font(.eulaFootnote)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Metrics.padding)
        .padding(.top, Metrics.padding)
        .padding(.bottom, Metrics.actionBottomPadding)
    }

    var continueButton: some View {
        Button(action: onAccept) {
            Text(.eulaContinueButton)
                .font(.eulaButton)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous))
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
