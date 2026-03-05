//
//  NewsScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct NewsScreen: View {
    @State private var viewModel = NewsScreenViewModel()

    var body: some View {
        ScrollView {
            // Article content will go here
        }
        .verticalToolbar(
            title: VerticalCard.news.title,
            color: VerticalCard.news.color,
            onSettingsClick: {}
        )
    }
}

#Preview {
    NavigationStack {
        NewsScreen()
    }
}
