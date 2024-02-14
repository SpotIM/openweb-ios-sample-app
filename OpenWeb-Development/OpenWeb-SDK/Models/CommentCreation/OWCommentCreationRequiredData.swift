//
//  OWCommentCreationRequiredData.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

struct OWCommentCreationRequiredData {
    let article: OWArticleProtocol
    let settings: OWAdditionalSettingsProtocol
    var commentCreationType: OWCommentCreationTypeInternal
    let presentationalStyle: OWPresentationalModeCompact
}
