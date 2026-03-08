//
//  VerticalToolbarModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalToolbarModifier: ViewModifier {
    var title: LocalizedStringKey
    var color: Color
    var onSettingsClick: () -> Void

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: onSettingsClick) {
                        Image(systemName: "gearshape")
                    }
                }
                .sharedBackgroundVisibility(.hidden)
            }
    }
}

extension View {
    func verticalToolbar(title: LocalizedStringKey, color: Color, onSettingsClick: @escaping () -> Void) -> some View {
        modifier(VerticalToolbarModifier(title: title, color: color, onSettingsClick: onSettingsClick))
    }
}
