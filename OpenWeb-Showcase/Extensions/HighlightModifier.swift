//
//  HighlightModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 25/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// MARK: - Environment

private struct ActiveHighlightIDKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var activeHighlightID: String? {
        get { self[ActiveHighlightIDKey.self] }
        set { self[ActiveHighlightIDKey.self] = newValue }
    }
}

// MARK: - Row Highlight

/// Row Highlight
struct HighlightModifier: ViewModifier {
    private struct Metrics {
        static let animationDuration: Double = 0.5
    }

    var isHighlighted: Bool

    func body(content: Content) -> some View {
        content
            .listRowBackground(
                Color(isHighlighted ? .systemGray5 : .secondarySystemGroupedBackground)
                    .animation(.easeInOut(duration: Metrics.animationDuration), value: isHighlighted)
            )
    }
}

extension View {
    func settingsHighlight(_ isHighlighted: Bool) -> some View {
        modifier(HighlightModifier(isHighlighted: isHighlighted))
    }

    func settingsRow(_ entryID: String) -> some View {
        modifier(SettingsRowHighlightModifier(entryID: entryID))
    }
}

private struct SettingsRowHighlightModifier: ViewModifier {
    var entryID: String
    @Environment(\.activeHighlightID) private var activeHighlightID

    func body(content: Content) -> some View {
        content
            .id(entryID)
            .settingsHighlight(activeHighlightID == entryID)
    }
}

// MARK: - Scroll & Highlight

struct ScrollHighlightModifier: ViewModifier {
    private struct Metrics {
        static let scrollDelay: Double = 0.3
        static let highlightDuration: Double = 1.0
    }

    var highlightedEntryID: String?
    @State private var activeHighlightID: String?

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .environment(\.activeHighlightID, activeHighlightID)
                .onAppear {
                    guard let highlightedEntryID else { return }
                    Task { @MainActor in
                        try? await Task.sleep(for: .seconds(Metrics.scrollDelay))
                        withAnimation {
                            proxy.scrollTo(highlightedEntryID, anchor: .center)
                        }
                        activeHighlightID = highlightedEntryID
                        try? await Task.sleep(for: .seconds(Metrics.highlightDuration))
                        withAnimation {
                            activeHighlightID = nil
                        }
                    }
                }
        }
    }
}

extension View {
    func scrollAndHighlight(entryID: String?) -> some View {
        modifier(ScrollHighlightModifier(highlightedEntryID: entryID))
    }
}
