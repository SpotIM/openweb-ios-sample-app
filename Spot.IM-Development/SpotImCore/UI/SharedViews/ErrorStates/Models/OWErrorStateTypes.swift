//
//  OWErrorStateTypes.swift
//  SpotImCore
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWErrorStateTypes {
    case none
    case loadConversationComments
    case loadMoreConversationComments
    case loadConversationReplies(commentPresentationData: OWCommentPresentationData)
}

extension OWErrorStateTypes: Equatable {
    static func == (lhs: OWErrorStateTypes, rhs: OWErrorStateTypes) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.loadConversationComments, .loadConversationComments):
            return true
        case (.loadMoreConversationComments, .loadMoreConversationComments):
            return true
        case (let .loadConversationReplies(lhsId), let .loadConversationReplies(rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}
