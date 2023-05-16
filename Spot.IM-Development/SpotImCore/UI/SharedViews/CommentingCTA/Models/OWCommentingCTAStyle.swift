//
//  OWCommentingCTAStyle.swift
//  SpotImCore
//
//  Created by Revital Pisman on 07/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommentingCTAStyle {
    case cta
    case conversationEnded
    case skelaton
}

#else
enum OWCommentingCTAStyle {
    case cta
    case conversationEnded
    case skelaton
}
#endif
