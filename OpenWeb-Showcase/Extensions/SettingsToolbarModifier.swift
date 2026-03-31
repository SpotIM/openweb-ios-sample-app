//
//  SettingsToolbarModifier.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SettingsToolbarModifier: ViewModifier {
    @State private var showAlert = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .alert(.resetAlertTitle, isPresented: $showAlert) {
                Button(.resetAlertCancel, role: .cancel) {}
                Button(.resetAlertConfirm, role: .destructive) {
                    SettingsStore.shared.resetAll()
                }
            } message: {
                Text(.resetAlertMessage)
            }
    }
}

extension View {
    func settingsToolbar() -> some View {
        modifier(SettingsToolbarModifier())
    }
}
