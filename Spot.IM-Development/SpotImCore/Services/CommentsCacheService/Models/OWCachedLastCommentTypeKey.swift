//
//  OWCachedLastCommentTypeKey.swift
//  SpotImCore
//
//  Created by Refael Sommer on 09/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCachedLastCommentTypeKey {
    case comment
    case reply(comment: OWComment)
    case edit(comment: OWComment)
}

extension OWCachedLastCommentTypeKey: Equatable {
    static func == (lhs: OWCachedLastCommentTypeKey, rhs: OWCachedLastCommentTypeKey) -> Bool {
        switch (lhs, rhs) {
        case (let .reply(lhsComment), let .reply(rhsComment)):
            return lhsComment.id == rhsComment.id
        case (let .edit(lhsComment), let .edit(rhsComment)):
            return lhsComment.id == rhsComment.id
        default: return false
        }
    }
}

extension OWCachedLastCommentTypeKey {
    var toCommentCreationTypeInternal: OWCommentCreationTypeInternal {
        switch self {
        case .comment:
            return .comment
        case .reply(comment: let comment):
            return .replyToComment(originComment: comment)
        case .edit(comment: let comment):
            return .edit(comment: comment)
        }
    }
}
