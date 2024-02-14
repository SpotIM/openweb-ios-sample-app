//
//  OWCommentThreadRequiredData.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/02/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct OWCommentThreadRequiredData {
    let article: OWArticleProtocol
    let settings: OWAdditionalSettingsProtocol
    let commentId: OWCommentId
    let presentationalStyle: OWPresentationalModeCompact
}
