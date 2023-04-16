//
//  OWViewActionCallbackType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case writeCommentPressed
    case articleHeaderPressed
    case communityGuidelinesPressed
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
}
#else
enum OWViewActionCallbackType: Codable {
    case contentPressed
    case showMoreCommentsPressed
    case writeCommentPressed
    case articleHeaderPressed
    case communityGuidelinesPressed
    case communityQuestionsPressed
    case postCommentPressed
    case adClosed
    case adTapped
}
#endif
