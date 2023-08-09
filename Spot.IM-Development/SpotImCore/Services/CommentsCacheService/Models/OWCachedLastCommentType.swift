//
//  OWCachedLastCommentTypeKey.swift
//  SpotImCore
//
//  Created by Refael Sommer on 09/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCachedLastCommentType {
    case newComment
    case reply(originComment: OWComment)
    case edit(comment: OWComment)
}

extension OWCachedLastCommentType: Equatable {
    static func == (lhs: OWCachedLastCommentType, rhs: OWCachedLastCommentType) -> Bool {
        switch (lhs, rhs) {
        case (let .reply(lhsComment), let .reply(rhsComment)):
            return lhsComment.id == rhsComment.id
        case (let .edit(lhsComment), let .edit(rhsComment)):
            return lhsComment.id == rhsComment.id
        default: return false
        }
    }
}

extension OWCachedLastCommentType {
    var toCommentCreationTypeInternal: OWCommentCreationTypeInternal {
        switch self {
        case .newComment:
            return .comment
        case .reply(originComment: let comment):
            return .replyToComment(originComment: comment)
        case .edit(comment: let comment):
            return .edit(comment: comment)
        }
    }
}
