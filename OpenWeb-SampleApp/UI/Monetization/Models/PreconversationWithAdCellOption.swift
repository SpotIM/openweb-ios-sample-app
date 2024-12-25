//
//  PreconversationWithAdCellOption.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/12/2024.
//

import Foundation
import RxSwift

enum PreconversationWithAdCellOption: CaseIterable {
    static var allCases: [PreconversationWithAdCellOption] {
        return [.image,
                .content,
                .independentAd,
                .content,
                .preconversation]
    }

    case image
    case content
    case independentAd
    case preconversation

    var cellClass: UITableViewCell.Type {
        switch self {
        case .image:
            return ArticleImageCell.self
        case .content:
            return ArticleContentCell.self
        case .independentAd:
            return IndependentAdCell.self
        case .preconversation:
            return PreConversationCell.self
        }
    }
}
