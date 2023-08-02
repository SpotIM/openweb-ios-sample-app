//
//  OWCommentUpdaterService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentUpdaterServicing {
    func update(comments: [OWComment], postId: OWPostId)
    func getUpdatedComments(for postId: OWPostId) -> Observable<[OWComment]>
}

class OWCommentUpdaterService: OWCommentUpdaterServicing {

    var _updatedCommentsWithPostId = PublishSubject<([OWComment], OWPostId)>()

    func update(comments: [OWComment], postId: OWPostId) {
        _updatedCommentsWithPostId.onNext((comments, postId))
    }

    func getUpdatedComments(for postId: OWPostId) -> Observable<[OWComment]> {
        return _updatedCommentsWithPostId
            .filter { $0.1 == postId }
            .map { $0.0 }
            .asObservable()
    }
}
