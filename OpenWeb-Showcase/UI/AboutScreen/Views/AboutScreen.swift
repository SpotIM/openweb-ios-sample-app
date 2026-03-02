//
//  AboutScreen.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

struct AboutScreen: View {
    private struct Metrics {
        static let logoSize: CGFloat = 80
        static let contentPadding: CGFloat = 24
        static let logoBottomSpacing: CGFloat = 24
        static let titleFontSize: CGFloat = 20
        static let titleBottomSpacing: CGFloat = 16
        static let descriptionFontSize: CGFloat = 14
        static let descriptionLineHeight: CGFloat = 26
        static let sectionTitleTopSpacing: CGFloat = 40
        static let sectionTitleFontSize: CGFloat = 14
        static let sectionTitleBottomSpacing: CGFloat = 16
        static let resourceItemSpacing: CGFloat = 12
        static let bottomSpacing: CGFloat = 24
    }

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AboutScreenViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("openweb_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Metrics.logoSize, height: Metrics.logoSize)

                Spacer().frame(height: Metrics.logoBottomSpacing)

                Text(NSLocalizedString("aboutCompanyTitle", comment: ""))
                    .font(.system(size: Metrics.titleFontSize, weight: .bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Spacer().frame(height: Metrics.titleBottomSpacing)

                Text(NSLocalizedString("aboutCompanyDescription", comment: ""))
                    .font(.system(size: Metrics.descriptionFontSize))
                    .foregroundStyle(.primary)
                    .lineSpacing(Metrics.descriptionLineHeight - Metrics.descriptionFontSize)

                Spacer().frame(height: Metrics.sectionTitleTopSpacing)

                Text(NSLocalizedString("aboutLinksSectionTitle", comment: ""))
                    .font(.system(size: Metrics.sectionTitleFontSize, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer().frame(height: Metrics.sectionTitleBottomSpacing)

                VStack(spacing: Metrics.resourceItemSpacing) {
                    ForEach(viewModel.resources) { resource in
                        ResourceItemCard(item: resource)
                    }
                }

                Spacer().frame(height: Metrics.bottomSpacing)
            }
            .padding(Metrics.contentPadding)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle(NSLocalizedString("aboutScreenTitle", comment: ""))
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    AboutScreen()
}
