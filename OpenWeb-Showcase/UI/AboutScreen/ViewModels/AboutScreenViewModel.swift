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
            icon: "ic_info",
            url: URL(string: AppConstants.sdkDocsURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutGithubTitle", comment: ""),
            icon: "ic_github",
            url: URL(string: AppConstants.githubURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutPrivacyPolicyTitle", comment: ""),
            icon: "ic_privacy_policy",
            url: URL(string: AppConstants.privacyPolicyURL)
        ),
        ResourceItem(
            title: NSLocalizedString("aboutTermsTitle", comment: ""),
            icon: "ic_terms",
            url: URL(string: AppConstants.termsURL)
        )
    ]
}
