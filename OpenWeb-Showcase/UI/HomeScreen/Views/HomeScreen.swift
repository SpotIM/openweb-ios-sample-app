//
//  HomeScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

struct HomeScreen: View {
    private struct Metrics {
        static let gridSpacing: CGFloat = 12
        static let gridPadding: CGFloat = 16
        static let fontSizeSection: CGFloat = 14
        static let sectionHeaderLetterSpacing: CGFloat = 0.5
        static let sectionHeaderBottomPadding: CGFloat = 4
    }

    @State private var viewModel = HomeScreenViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: Metrics.gridSpacing),
        GridItem(.flexible(), spacing: Metrics.gridSpacing)
    ]

    var body: some View {
        VStack(spacing: 0) {
            HomeToolbar {
                // TODO: handle about tap
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: Metrics.gridSpacing) {
                    Section {
                        ForEach(viewModel.verticals, id: \.id) { vertical in
                            VerticalCardItem(vertical: vertical) {
                                // TODO: handle card tap
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("chooseVerticalSectionTitle", comment: ""))
                            .font(.system(size: Metrics.fontSizeSection, weight: .semibold))
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
}

#Preview {
    HomeScreen()
}
