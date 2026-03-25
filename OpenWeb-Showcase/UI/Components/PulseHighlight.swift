//
//  PulseHighlight.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 25/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

extension View {
    func pulseHighlight(
        tapped: Binding<Bool>,
        delay: TimeInterval = 2,
        interval: TimeInterval = 1,
        pulseCount: Int = 3
    ) -> some View {
        modifier(PulseHighlightModifier(tapped: tapped, delay: delay, interval: interval, pulseCount: pulseCount))
    }
}

private struct PulseHighlightModifier: ViewModifier {
    @Binding var tapped: Bool
    var delay: TimeInterval
    var interval: TimeInterval
    var pulseCount: Int

    @State private var isPulsing = false

    private struct Metrics {
        static let highlightColor = Color.yellow
        static let maxOpacity: Double = 0.5
        static let circlePadding: CGFloat = 5
        static let minScale: CGFloat = 0.6
    }

    func body(content: Content) -> some View {
        content
            .padding(Metrics.circlePadding)
            .background {
                Circle()
                    .fill(Metrics.highlightColor)
                    .scaleEffect(isPulsing ? 1 : Metrics.minScale)
                    .opacity(isPulsing ? Metrics.maxOpacity : 0)
                    .animation(.easeInOut(duration: interval * 0.4), value: isPulsing)
            }
            .padding(-Metrics.circlePadding)
            .task(id: tapped) {
                guard !tapped else { return }
                try? await Task.sleep(for: .seconds(delay))
                await runPulseCycles()
            }
    }

    private func runPulseCycles() async {
        while !tapped {
            for _ in 0..<pulseCount {
                guard !tapped else { return }
                isPulsing = true
                try? await Task.sleep(for: .seconds(interval * 0.4))
                isPulsing = false
                try? await Task.sleep(for: .seconds(interval * 0.6))
            }
            guard !tapped else { return }
            try? await Task.sleep(for: .seconds(delay))
        }
    }
}
