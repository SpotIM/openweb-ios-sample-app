//
//  SPConversationReadRM.swift
//  OpenWebSDK
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import Foundation

internal struct SPConversationReadRM: Decodable {
    let user: SPUser?
    let extractData: SPConversationExtraDataRM?
    let conversation: SPConversation?
    let abData: [SPABData]?
}
