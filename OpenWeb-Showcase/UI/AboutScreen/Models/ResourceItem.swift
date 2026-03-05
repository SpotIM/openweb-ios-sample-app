//
//  ResourceItem.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

enum ResourceIcon: String {
    case info = "ic_info"
    case github = "ic_github"
    case privacyPolicy = "ic_privacy_policy"
    case terms = "ic_terms"
}

struct ResourceItem: Identifiable {
    let id = UUID()
    var title: String
    var description: String?
    var icon: ResourceIcon
    var url: URL?
}
