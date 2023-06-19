//
//  OWCommentCreationStyle.swift
//  SpotImCore
//
//  Created by Alon Haiut on 17/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWCommentCreationStyle: Codable {
    case regular
    case light // Called new header before
    case floatingKeyboard
}

#else
enum OWCommentCreationStyle: Codable {
    case regular
    case light // Called new header before
    case floatingKeyboard
}
#endif
