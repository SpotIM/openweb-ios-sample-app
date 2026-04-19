//
//  ArticleData.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Foundation

struct ArticleContent {
    var imageURL: String
    var sourceName: String
    var readTime: String
    var subtitle: String
    var authorName: String
    var date: String
    var leadParagraph: String

    var authorInitials: String {
        authorName.split(separator: " ").compactMap { $0.first.map(String.init) }.joined()
    }
}

struct ArticleData {
    var spotId: String
    var postId: String
    var title: String
    var content: ArticleContent?
}
