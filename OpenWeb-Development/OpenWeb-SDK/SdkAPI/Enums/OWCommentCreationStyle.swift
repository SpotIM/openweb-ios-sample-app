//
//  OWCommentCreationStyle.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 17/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public enum OWCommentCreationStyle: Codable {
    case regular
    case light // Called new header before
    case floatingKeyboard(accessoryViewStrategy: OWAccessoryViewStrategy = .none)
}
