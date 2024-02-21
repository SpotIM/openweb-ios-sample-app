//
//  OWCoordinatorDataOptions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCoordinatorDataOptions {
    case highlightComment(commentId: OWCommentId)
    case commentCreation(commentCreationData: OWCommentCreationRequiredData, source: OWViewSourceType)
    case commentThread(commentThreadData: OWCommentThreadRequiredData)
    case authentication
    case reportReason(reportData: OWReportReasonsRequiredData)
    case clarityDetails(type: OWClarityDetailsType)
}
