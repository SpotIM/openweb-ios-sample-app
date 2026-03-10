//
//  ResourceItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

enum ResourceItem: Identifiable, CaseIterable {
    case sdkDocs
    case github
    case privacyPolicy
    case terms

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .sdkDocs: .aboutSdkDocsTitle
        case .github: .aboutGithubTitle
        case .privacyPolicy: .aboutPrivacyPolicyTitle
        case .terms: .aboutTermsTitle
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
        case .sdkDocs: URL(string: "https://developers.openweb.com/docs/android-social-sdk-getting-started")!
        case .github: URL(string: "https://github.com/SpotIM/spotim-android-sample-app")! // TODO: change to iOS repo
        case .privacyPolicy: URL(string: "https://www.openweb.com/privacy")!
        case .terms: URL(string: "https://www.openweb.com/terms")!
        }
    }
}
