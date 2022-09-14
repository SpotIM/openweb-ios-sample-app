//
//  OWDeepLinkOptions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

import Foundation

enum OWDeepLinkOptions {
    case highlightComment(commentId: String)
    case commentCreation(commentCreationData: OWCommentCreationRequiredData)
    case authentication
}
