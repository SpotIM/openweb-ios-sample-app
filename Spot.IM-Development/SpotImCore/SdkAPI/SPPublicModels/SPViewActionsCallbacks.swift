//
//  SPViewActionsCallbacks.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

public typealias SPViewActionsCallbacks = (SPViewActionCallbackType, SPViewSourceType, String) -> Void

public enum SPViewSourceType {
    case preConversation
    case conversation
    case createComment
    case login

    public var description: String {
        switch self {
        case .preConversation:
            return "Pre-Conversation screen"
        case .conversation:
            return "Conversation screen"
        case .createComment:
            return "Create Comment screen"
        case .login:
            return "Login screen"
        }
    }
}

public enum SPViewActionCallbackType {
    case articleHeaderPressed
    case openUserProfile(userId: String, navigationController: UINavigationController)
}
