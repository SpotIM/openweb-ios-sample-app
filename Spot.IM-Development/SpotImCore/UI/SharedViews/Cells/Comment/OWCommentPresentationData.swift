//
//  OWCommentPresentationData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

struct OWCommentPresentationData { // TODO: Should be class and implement equtable
    let id: String
    let shouldShowReplies: Bool // open / showingFirst(replies)
    let repliesIds: [String]
    let totalRepliesCount: Int
    let repliesOffset: Int
    let repliesPresentation: [OWCommentPresentationData]
}
