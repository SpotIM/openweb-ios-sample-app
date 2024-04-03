//
//  OWCommentCreationCtaData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentCreationCtaData {
    var commentContent: OWCommentCreationContent
    let commentLabelIds: [String]
    let commentUserMentions: [OWUserMentionObject]?
}
