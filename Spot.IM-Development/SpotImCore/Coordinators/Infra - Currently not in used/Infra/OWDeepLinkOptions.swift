//
//  OWDeepLinkOptions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 01/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWDeepLinkOptions {
    case highlightComment(commentId: String)
    case commentCreation(commentCreationData: OWCommentCreationRequiredData)
    case commentThread(commentThreadData: OWCommentThreadRequiredData)
    case authentication
    case reportReason(reportReasonSubmitted: Observable<OWCommentId>)
}
