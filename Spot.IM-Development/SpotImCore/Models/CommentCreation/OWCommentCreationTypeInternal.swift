//
//  OWCommentCreationTypeInternal.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 03/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentCreationTypeInternal {
    case comment
    case edit(comment: OWComment)
    case replyToComment(originComment: OWComment)
}
