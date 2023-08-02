//
//  OWCommentUpdaterService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

enum OWCommentUpdateType {
    case insert(comments: [OWComment])
    case update(commentId: OWCommentId, withComment: OWComment)
}

protocol OWCommentUpdaterServicing {
    func update(_ updateType: OWCommentUpdateType, postId: OWPostId)
    func getUpdatedComments(for postId: OWPostId) -> Observable<OWCommentUpdateType>
}

class OWCommentUpdaterService: OWCommentUpdaterServicing {
    var _updatedCommentsWithPostId = PublishSubject<(OWCommentUpdateType, OWPostId)>()

    func update(_ updateType: OWCommentUpdateType, postId: OWPostId) {
        _updatedCommentsWithPostId.onNext((updateType, postId))
    }

    func getUpdatedComments(for postId: OWPostId) -> RxSwift.Observable<OWCommentUpdateType> {
        return _updatedCommentsWithPostId
            .filter { $0.1 == postId }
            .map { $0.0 }
            .asObservable()
    }
}
