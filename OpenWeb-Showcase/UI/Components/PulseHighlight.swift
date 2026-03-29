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
        isOn: Binding<Bool>,
        highlightColor: Color = .yellow,
        delay: TimeInterval = 2,
        interval: TimeInterval = 1,
        pulseCount: Int = 3
    ) -> some View {
        modifier(PulseHighlightModifier(isOn: isOn, highlightColor: highlightColor, delay: delay, interval: interval, pulseCount: pulseCount))
    }
}

private struct PulseHighlightModifier: ViewModifier {
    @Binding var isOn: Bool
    var highlightColor: Color
    var delay: TimeInterval
    var interval: TimeInterval
    var pulseCount: Int

    @State private var isPulsing = false

    private struct Metrics {
        static let maxOpacity: Double = 0.5
        static let circlePadding: CGFloat = 8
        static let minScale: CGFloat = 0.6
        static let pulseOnRatio: Double = 0.4
        static let pulseOffRatio: Double = 0.6
    }

    func body(content: Content) -> some View {
        content
            .padding(Metrics.circlePadding)
            .background {
                Circle()
                    .fill(highlightColor)
                    .scaleEffect(isPulsing ? 1 : Metrics.minScale)
                    .opacity(isPulsing ? Metrics.maxOpacity : 0)
                    .animation(.easeInOut(duration: interval * Metrics.pulseOnRatio), value: isPulsing)
            }
            .padding(-Metrics.circlePadding)
            .task(id: isOn) {
                guard isOn else { return }
                try? await Task.sleep(for: .seconds(delay))
                await runPulseCycles()
            }
    }

    private func runPulseCycles() async {
        while isOn {
            for _ in 0..<pulseCount {
                guard isOn else { return }
                isPulsing = true
                try? await Task.sleep(for: .seconds(interval * Metrics.pulseOnRatio))
                isPulsing = false
                try? await Task.sleep(for: .seconds(interval * Metrics.pulseOffRatio))
            }
            guard isOn else { return }
            try? await Task.sleep(for: .seconds(delay))
        }
    }
}
