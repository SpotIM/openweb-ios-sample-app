//
//  OWCommentRequiredData.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 03/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentRequiredData {
    let comment: SPComment
    let user: SPUser
    let replyToUser: SPUser?
    let collapsableTextLineLimit: Int
}
