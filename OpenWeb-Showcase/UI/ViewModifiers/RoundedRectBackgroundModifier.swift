//
//  RoundedRectBackgroundModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct RoundedRectBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat
    var color: Color

    func body(content: Content) -> some View {
        content.background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color)
        }
    }
}

extension View {
    func roundedRectBackground(
        cornerRadius: CGFloat,
        color: Color = Color(uiColor: .systemBackground)
    ) -> some View {
        modifier(RoundedRectBackgroundModifier(cornerRadius: cornerRadius, color: color))
    }
}
