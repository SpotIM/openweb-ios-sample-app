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
        Text(viewModel.article.title)
            .navigationTitle("newsScreenTitle")
    }
}

#Preview {
    NavigationStack {
        NewsScreen()
    }
}
