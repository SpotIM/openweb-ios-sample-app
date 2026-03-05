//
//  ResourceItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum ResourceItem: String, Identifiable, CaseIterable {
    case sdkDocs
    case github
    case privacyPolicy
    case terms

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .sdkDocs: "aboutSdkDocsTitle"
        case .github: "aboutGithubTitle"
        case .privacyPolicy: "aboutPrivacyPolicyTitle"
        case .terms: "aboutTermsTitle"
        }
    }

    var icon: ImageResource {
        switch self {
        case .sdkDocs: .icInfo
        case .github: .icGithub
        case .privacyPolicy: .icPrivacyPolicy
        case .terms: .icTerms
        }
    }

    var url: URL {
        switch self {
        case .sdkDocs: URL(string: AppConstants.sdkDocsURL)!
        case .github: URL(string: AppConstants.githubURL)!
        case .privacyPolicy: URL(string: AppConstants.privacyPolicyURL)!
        case .terms: URL(string: AppConstants.termsURL)!
        }
    }
}
