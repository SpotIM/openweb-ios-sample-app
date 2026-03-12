//
//  VerticalPager.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 12/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalPager<Content: View>: View {
    private struct Metrics {
        static var swipeThreshold: Int { 20 }
        static var springResponse: Double { 0.3 }
}

    let pageCount: Int
    @Binding var currentIndex: Int
    let content: Content

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
                    let offset = -Int(value.translation.height)
                    if abs(offset) > Metrics.swipeThreshold {
                        let newIndex = currentIndex + min(max(offset, -1), 1)
                        if newIndex >= 0 && newIndex < pageCount {
                            currentIndex = newIndex
                        }
                    }
                }
            )
        }
    }
}
