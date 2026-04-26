//
//  ContentView.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("showcase.eulaAccepted") private var eulaAccepted = false

    var body: some View {
        HomeScreen()
            .sheet(isPresented: showEULA) {
                EULAView { eulaAccepted = true }
                    .interactiveDismissDisabled()
            }
    }

    private var showEULA: Binding<Bool> {
        Binding(
            get: { !eulaAccepted },
            set: { _ in }
        )
    }
}

#Preview {
    ContentView()
}
