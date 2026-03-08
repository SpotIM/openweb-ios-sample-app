//
//  RoundedRectBorderModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct RoundedRectBorderModifier: ViewModifier {
    var cornerRadius: CGFloat
    var color: Color
    var width: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color, lineWidth: width)
        }
    }
}

extension View {
    func roundedRectBorder(
        cornerRadius: CGFloat,
        color: Color = Color(uiColor: .separator),
        width: CGFloat = 1
    ) -> some View {
        modifier(RoundedRectBorderModifier(cornerRadius: cornerRadius, color: color, width: width))
    }
}
