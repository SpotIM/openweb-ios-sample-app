//
//  OWCommentCreationCtaData.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 30/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWCommentCreationCtaData {
    var commentContent: OWCommentCreationContent
    let commentLabelIds: [String]
    let commentUserMentions: [OWUserMentionObject]?
}
