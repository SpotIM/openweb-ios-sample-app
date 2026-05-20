//
//  VerticalToolbarModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 05/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct VerticalToolbarModifier: ViewModifier {
    var title: LocalizedStringResource
    var color: Color

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(value: Destination.settings) {
                        Image(systemName: "gearshape")
                    }
                }
            }
    }
}

extension View {
    func verticalToolbar(title: LocalizedStringResource, color: Color) -> some View {
        modifier(VerticalToolbarModifier(title: title, color: color))
    }
}
