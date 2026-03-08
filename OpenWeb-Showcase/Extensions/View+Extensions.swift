//
//  View+Extensions.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

extension View {
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
