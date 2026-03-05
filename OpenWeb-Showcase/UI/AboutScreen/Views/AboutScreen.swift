//
//  AboutScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct AboutScreen: View {
    private struct Metrics {
        static let logoSize: CGFloat = 80
        static let contentPadding: CGFloat = 24
        static let logoBottomSpacing: CGFloat = 24
        static let titleBottomSpacing: CGFloat = 16
        static let descriptionLineSpacing: CGFloat = 12
        static let sectionTitleTopSpacing: CGFloat = 40
        static let sectionTitleBottomSpacing: CGFloat = 16
        static let resourceItemSpacing: CGFloat = 12
        static let bottomSpacing: CGFloat = 24
    }

    @State private var viewModel = AboutScreenViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                logoView
                Spacer().frame(height: Metrics.logoBottomSpacing)
                titleView
                Spacer().frame(height: Metrics.titleBottomSpacing)
                descriptionView
                Spacer().frame(height: Metrics.sectionTitleTopSpacing)
                sectionTitleView
                Spacer().frame(height: Metrics.sectionTitleBottomSpacing)
                resourcesListView
                Spacer().frame(height: Metrics.bottomSpacing)
            }
            .padding(Metrics.contentPadding)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("aboutScreenTitle")
    }
}

// MARK: - Subviews

private extension AboutScreen {
    var logoView: some View {
        Image(.openwebLogo)
            .resizable()
            .scaledToFit()
            .frame(width: Metrics.logoSize, height: Metrics.logoSize)
    }

    var titleView: some View {
        Text("aboutCompanyTitle")
            .font(.screenTitle)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.center)
    }

    var descriptionView: some View {
        Text("aboutCompanyDescription")
            .font(.bodyText)
            .foregroundStyle(.primary)
            .lineSpacing(Metrics.descriptionLineSpacing)
    }

    var sectionTitleView: some View {
        Text("aboutLinksSectionTitle")
            .font(.sectionTitle)
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var resourcesListView: some View {
        VStack(spacing: Metrics.resourceItemSpacing) {
            ForEach(viewModel.resources) { resource in
                ResourceItemCard(item: resource)
            }
        }
    }
}

#Preview {
    AboutScreen()
}
