//
//  OWAppealRequiredData.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 22/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

public struct OWAppealRequiredData: Codable {
    internal let commentId: OWCommentId
    internal let reasons: [OWAppealReason]
}
