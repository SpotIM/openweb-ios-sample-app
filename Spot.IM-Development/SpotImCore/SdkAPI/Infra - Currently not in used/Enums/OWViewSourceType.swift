//
//  OWViewSourceType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWViewSourceType {
    case preConversation
    case conversation
    case commentCreation
    case commentThread
    case reportReason
}
#else
enum OWViewSourceType {
    case preConversation
    case conversation
    case commentCreation
    case commentThread
}
#endif
