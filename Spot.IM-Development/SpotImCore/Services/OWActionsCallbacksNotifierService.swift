//
//  OWActionsCallbacksNotifierService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 06/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

/*
 * This service was created in order to notify about action callbacks,
 * specifically for independent UIViews mode
 */

import Foundation
import RxSwift

protocol OWActionsCallbacksNotifierServicing {
    func openCommentThread(commentId: OWCommentId, performAction: OWCommentThreadPerformActionType)
    var openCommentThread: Observable<(OWCommentId, OWCommentThreadPerformActionType)> { get }
}

class OWActionsCallbacksNotifierService: OWActionsCallbacksNotifierServicing {
    fileprivate let _openCommentThread = PublishSubject<(OWCommentId, OWCommentThreadPerformActionType)>()
    var openCommentThread: Observable<(OWCommentId, OWCommentThreadPerformActionType)> {
        _openCommentThread
            .asObservable()
    }

    func openCommentThread(commentId: OWCommentId, performAction: OWCommentThreadPerformActionType) {
        _openCommentThread.onNext((commentId, performAction))
    }
}
