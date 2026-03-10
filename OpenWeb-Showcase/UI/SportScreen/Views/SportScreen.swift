//
//  SportScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct SportScreen: View {
    @StateObject private var viewModel = SportScreenViewModel()

    var body: some View {
        Text(viewModel.title)
            .font(.largeTitle)
            .navigationTitle(viewModel.title)
    }
}

#Preview {
    NavigationStack {
        SportScreen()
    }
}
