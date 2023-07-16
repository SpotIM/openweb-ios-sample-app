//
//  OWCommentCreationRequestsService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWCommentCreationRequestsServicing {
    var newRequest: Observable<OWCommentCreationRequestOption> { get }
    func triggerRequest(_ request: OWCommentCreationRequestOption)
}

class OWCommentCreationRequestsService: OWCommentCreationRequestsServicing {

    fileprivate let _newRequest = PublishSubject<OWCommentCreationRequestOption>()
    var newRequest: Observable<OWCommentCreationRequestOption> {
        return _newRequest
            .asObservable()
    }

    func triggerRequest(_ request: OWCommentCreationRequestOption) {
        _newRequest.onNext(request)
    }
}
