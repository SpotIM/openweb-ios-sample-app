//
//  SPConfigurationShared.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 07/04/2021.
//  Copyright © 2021 OpenWeb. All rights reserved.
//

import Foundation

struct SPConfigurationShared: Decodable {

    let enableCommentLabels: Bool?
    let commentLabels: Dictionary<String, SPCommentLabelsSectionConfiguration>?
    let votesType: OWVotesType
    let usePublisherUserProfile: Bool?
    let reportReasonsOptions: OWConfigurationReportReasonOptions?
    let reportReasonsMinimumAdditionalTextLength: Int?

    enum CodingKeys: String, CodingKey {
        case usePublisherUserProfile = "useCustomUserProfile"
        case enableCommentLabels,
             commentLabels,
             votesType,
             reportReasonsOptions,
             reportReasonsMinimumAdditionalTextLength
    }
}
