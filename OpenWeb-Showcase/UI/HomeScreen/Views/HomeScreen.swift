//
//  HomeScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct HomeScreen: View {
    private struct Metrics {
        static let gridSpacing: CGFloat = 12
        static let gridPadding: CGFloat = 16
        static let sectionHeaderLetterSpacing: CGFloat = 0.5
        static let sectionHeaderBottomPadding: CGFloat = 4
    }

    @StateObject private var viewModel = HomeScreenViewModel()
    @State private var navigationPath = NavigationPath()

    private let columns = [
        GridItem(.flexible(), spacing: Metrics.gridSpacing),
        GridItem(.flexible(), spacing: Metrics.gridSpacing),
    ]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HomeToolbar {
                    navigationPath.append(Destination.about)
                }
                verticalsGridView
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .about:
                    AboutScreen()
                case .vertical(let card):
                    verticalScreen(for: card)
                }
            }
        }
    }
}

// MARK: - Navigation

private extension HomeScreen {
    @ViewBuilder
    func verticalScreen(for card: ShowcaseVertical) -> some View {
        switch card {
        case .news: NewsScreen()
        case .finance: FinanceScreen()
        default: EmptyView()
        }
    }
}

// MARK: - Subviews

private extension HomeScreen {
    var verticalsGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Metrics.gridSpacing) {
                Section {
                    ForEach(viewModel.verticals) { vertical in
                        VerticalCard(vertical: vertical) {
                            navigationPath.append(Destination.vertical(vertical))
                        }
                    }
                } header: {
                    Text(.chooseVerticalSectionTitle)
                        .font(.sectionTitle)
                        .foregroundStyle(.secondary)
                        .tracking(Metrics.sectionHeaderLetterSpacing)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, Metrics.sectionHeaderBottomPadding)
                }
            }
            .padding(Metrics.gridPadding)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

#Preview {
    HomeScreen()
}
