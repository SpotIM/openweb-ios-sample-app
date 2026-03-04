//
//  AboutScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//

import SwiftUI

@Observable
class AboutScreenViewModel {
    let resources: [ResourceItem] = [
        ResourceItem(
            title: NSLocalizedString("aboutSdkDocsTitle", comment: ""),
            icon: .info,
            url: URL(string: AppConstants.sdkDocsURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutGithubTitle", comment: ""),
            icon: .github,
            url: URL(string: AppConstants.githubURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutPrivacyPolicyTitle", comment: ""),
            icon: .privacyPolicy,
            url: URL(string: AppConstants.privacyPolicyURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutTermsTitle", comment: ""),
            icon: .terms,
            url: URL(string: AppConstants.termsURL)
        ),
    ]
}
