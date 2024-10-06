//
//  OWCommentCreationTypeInternal.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 03/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

enum OWCommentCreationTypeInternal {
    case comment
    case edit(comment: OWComment)
    case replyToComment(originComment: OWComment)
}

extension OWCommentCreationTypeInternal {
    var identifierDescription: String {
        switch self {
        case .comment:
            return "comment"
        case .edit:
            return "edit_comment"
        case .replyToComment:
            return "reply_to_comment"
        }
    }
}
