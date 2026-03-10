//
//  View+Extensions.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

extension View {
    func roundedRect(
        cornerRadius: CGFloat,
        background: Color? = Color(uiColor: .systemBackground),
        border: Color? = nil,
        borderWidth: CGFloat = 1
    ) -> some View {
        roundedRectBackground(cornerRadius: cornerRadius, color: background ?? .clear)
            .roundedRectBorder(cornerRadius: cornerRadius, color: border ?? .clear, width: borderWidth)
    }
}

// MARK: - Private

private extension View {
    func roundedRectBorder(
        cornerRadius: CGFloat,
        color: Color = Color(uiColor: .separator),
        width: CGFloat = 1
    ) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color, lineWidth: width)
        }
    }

    func roundedRectBackground(
        cornerRadius: CGFloat,
        color: Color = Color(uiColor: .systemBackground)
    ) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
        }
    }
}
