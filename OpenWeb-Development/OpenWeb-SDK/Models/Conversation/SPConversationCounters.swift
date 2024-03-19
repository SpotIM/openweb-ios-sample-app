//
//  SPConversationCounters.swift
//  OpenWebSDK
//
//  Created by Rotem Itzhak on 23/01/2020.
//  Copyright © 2020 OpenWeb. All rights reserved.
//

import Foundation

internal struct SPConversationCounters: Decodable {
    let comments: Int
    let replies: Int
}
