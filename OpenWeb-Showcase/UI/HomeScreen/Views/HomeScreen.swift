//
//  HomeScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

struct HomeScreen: View {
    @State private var viewModel = HomeScreenViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: HomeScreenDimensions.paddingMedium),
        GridItem(.flexible(), spacing: HomeScreenDimensions.paddingMedium)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: HomeScreenDimensions.paddingMedium) {
                    Section {
                        ForEach(viewModel.verticals, id: \.id) { vertical in
                            VerticalCardItem(vertical: vertical) {
                                // TODO: handle card tap
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("chooseVerticalSectionTitle", comment: ""))
                            .font(.system(size: HomeScreenDimensions.fontSizeSection, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4)
                    }
                }
                .padding(HomeScreenDimensions.paddingLarge)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(NSLocalizedString("homeTitle", comment: ""))
        }
    }
}

#Preview {
    HomeScreen()
}
