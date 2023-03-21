//
//  OWCommentPresentationData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentPresentationData {
    let id: String
    let shouldShowReplies: Bool
    let repliesIds: [String]
    let repliesCount: Int
    let repliesOffset: Int
    let repliesPresentation: [OWCommentPresentationData]
}
