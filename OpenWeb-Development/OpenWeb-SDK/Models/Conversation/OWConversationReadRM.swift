//
//  OWConversationReadRM.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 10/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

internal struct OWConversationReadRM: Decodable {
    let user: SPUser?
    let extractData: SPConversationExtraDataRM?
    let conversation: OWConversation?
    let abData: [SPABData]?
    let reportedComments: [OWCommentId: EmptyDecodable]?
}
