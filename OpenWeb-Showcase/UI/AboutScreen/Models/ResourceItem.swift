//
//  ResourceItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum ResourceItem: String, Identifiable, CaseIterable {
    case sdkDocs
    case github
    case privacyPolicy
    case terms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sdkDocs: NSLocalizedString("aboutSdkDocsTitle", comment: "")
        case .github: NSLocalizedString("aboutGithubTitle", comment: "")
        case .privacyPolicy: NSLocalizedString("aboutPrivacyPolicyTitle", comment: "")
        case .terms: NSLocalizedString("aboutTermsTitle", comment: "")
        }
    }

    var description: String? { nil }

    var icon: String {
        switch self {
        case .sdkDocs: "ic_info"
        case .github: "ic_github"
        case .privacyPolicy: "ic_privacy_policy"
        case .terms: "ic_terms"
        }
    }

    var url: URL? {
        switch self {
        case .sdkDocs: URL(string: AppConstants.sdkDocsURL)
        case .github: URL(string: AppConstants.githubURL)
        case .privacyPolicy: URL(string: AppConstants.privacyPolicyURL)
        case .terms: URL(string: AppConstants.termsURL)
        }
    }
}
