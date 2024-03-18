//
//  OWConversationScanData.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 19/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWConversationScanData {
    var commentVMsUpdateComment: [(OWCommentViewModeling, OWCommentViewModeling)] = []
    var commentVMsUpdateUser: [(OWCommentViewModeling, OWCommentViewModeling)] = []
    var cellOptions: [OWConversationCellOption]

    static var empty: OWConversationScanData {
        return OWConversationScanData(cellOptions: [])
    }
}
