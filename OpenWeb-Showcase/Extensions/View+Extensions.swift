//
//  View+Extensions.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

extension View {
    func squareFrame(size: CGFloat) -> some View {
        frame(width: size, height: size)
    }

    func roundedRect(
        cornerRadius: CGFloat,
        background: Color? = nil,
        border: Color? = nil,
        borderWidth: CGFloat = 1
    ) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background ?? .clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(border ?? .clear, lineWidth: borderWidth)
            }
    }
}
