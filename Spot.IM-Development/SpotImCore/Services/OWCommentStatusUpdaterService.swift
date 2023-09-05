//
//  OWCommentStatusUpdaterService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 04/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentStatusUpdaterServicing {
    func fetchStatusFor(comment: OWComment)
    func stopUpdating()
}

class OWCommentStatusUpdaterService {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let scheduler: SchedulerType
    fileprivate var disposeBag: DisposeBag

    init (
        servicesProvider: OWSharedServicesProviding,
        scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .utility, internalSerialQueueName: "OpenWebSDKStatusUpdaterServiceQueue")
    ) {
        self.servicesProvider = servicesProvider
        self.scheduler = scheduler
        self.disposeBag = DisposeBag()
    }

    func fetchStatusFor(comment: OWComment) {
        // Use OWCommentUpdaterService to update
    }

    func stopUpdating() {
        self.disposeBag = DisposeBag()
    }
}

fileprivate extension OWCommentStatusUpdaterService {
    func getRawStatus(for comment: OWComment) -> Observable<String> {
        guard let commentId = comment.id else { return .empty() }

        return self.servicesProvider
            .netwokAPI()
            .conversation
            .commentStatus(commentId: commentId)
            .response
            .map { response in
                guard let status = response["status"],
                      status != "processing" else { return nil }
                return status
            }
            .unwrap()
    }
}
