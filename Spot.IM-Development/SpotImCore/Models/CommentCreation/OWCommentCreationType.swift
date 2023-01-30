//
//  OWCommentCreationType.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 03/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

enum OWCommentCreationType {
    case comment
    case replyToComment(originComment: SPComment)
}
