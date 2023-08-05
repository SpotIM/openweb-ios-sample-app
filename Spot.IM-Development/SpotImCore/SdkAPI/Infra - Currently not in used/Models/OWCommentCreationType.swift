//
//  OWCommentCreationType.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommentCreationType {
    case comment
    case edit(commentId: OWCommentId)
    case replyTo(commentId: OWCommentId)
}

#else
enum OWCommentCreationType {
    case comment
    case edit(commentId: OWCommentId)
    case replyTo(commentId: OWCommentId)
}
#endif
