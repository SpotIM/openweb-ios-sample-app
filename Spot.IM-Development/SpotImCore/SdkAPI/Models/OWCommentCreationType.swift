//
//  OWCommentCreationType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum OWCommentCreationType: Codable {
    case comment
    case edit(commentId: OWCommentId)
    case replyTo(commentId: OWCommentId)
}

extension OWCommentCreationType: Equatable {
    public static func == (lhs: OWCommentCreationType, rhs: OWCommentCreationType) -> Bool {
        switch (lhs, rhs) {
        case (.comment, .comment):
            return true
        case let (.edit(lhsId), .edit(rhsId)):
            return lhsId == rhsId
        case let (.replyTo(lhsId), .replyTo(rhsId)):
            return lhsId == rhsId
        default:
            return false
        }
    }
}
