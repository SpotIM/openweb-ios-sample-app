//
//  VerticalPager.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

private struct Metrics {
    static let swipeThreshold: CGFloat = 20
    static let springResponse: Double = 0.3
}

struct VerticalPager<Content: View>: View {
    var pageCount: Int
    @Binding var currentIndex: Int
    var content: Content

    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        _currentIndex = currentIndex
        self.content = content()
    }

    @GestureState private var translation: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            LazyVStack(spacing: 0) {
                content.frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .offset(y: -CGFloat(currentIndex) * geometry.size.height)
            .offset(y: translation)
            .animation(.interactiveSpring(response: Metrics.springResponse), value: currentIndex)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture(minimumDistance: 1).updating($translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let offset = -value.translation.height
                    if abs(offset) > Metrics.swipeThreshold {
                        let direction = offset > 0 ? 1 : -1
                        let newIndex = currentIndex + direction
                        if newIndex >= 0 && newIndex < pageCount {
                            currentIndex = newIndex
                        }
                    }
                }
            )
        }
    }
}
