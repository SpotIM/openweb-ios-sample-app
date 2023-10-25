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
    func spotChanged(newSpotId: OWSpotId)
}

class OWCommentStatusUpdaterService: OWCommentStatusUpdaterServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var disposeBag: DisposeBag = DisposeBag()

    fileprivate struct Metrics {
        static let retriesDefault: Int = 12
        static let timeoutDefault: Int = 3000
        static let intervalDefault: Int = 300
    }

    init (
        servicesProvider: OWSharedServicesProviding
    ) {
        self.servicesProvider = servicesProvider
        self.setupObservers()
    }

    fileprivate var retries: Int = Metrics.retriesDefault
    fileprivate var timeout: Int = Metrics.timeoutDefault
    fileprivate var interval: Int = Metrics.intervalDefault

    fileprivate let _fetchStatusFor = PublishSubject<OWComment>()
    func fetchStatusFor(comment: OWComment) {
        _fetchStatusFor.onNext(comment)
    }

    func spotChanged(newSpotId: OWSpotId) {
        disposeBag = DisposeBag()
        setupObservers()
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
                let status = response.status
                guard status != "processing" else {
                    throw OWCommentStatusError.processingStatus
                }
                return status
            }
            .retry(maxAttempts: retries, millisecondsDelay: interval)
            .materialize()
            .map { event -> String? in
                switch event {
                case .next(let status):
                    return status
                case .error(_):
                    return nil
                default:
                    return nil
                }

            }
            .unwrap()
    }

    func setupObservers() {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .subscribe(onNext: { [weak self] config in
                guard let self = self,
                      let convConfig = config.conversation else { return }
                self.retries = convConfig.statusFetchRetryCount
                self.interval = convConfig.statusFetchIntervalInMs
                self.timeout = convConfig.statusFetchTimeoutInMs
            })
            .disposed(by: disposeBag)

        _fetchStatusFor
            .flatMap { [weak self] comment -> Observable<(String, OWComment)> in
                guard let self = self else { return .empty() }
                return self.getRawStatus(for: comment)
                    .map { ($0, comment) }
            }
            .subscribe(onNext: { [weak self] (status, comment) in
                guard let self = self,
                      let commentId = comment.id,
                      let postId = OWManager.manager.postId
                else { return }
                var newComment = comment
                newComment.rawStatus = status
                self.servicesProvider.conversationUpdaterService()
                    .update(.update(commentId: commentId, withComment: newComment), postId: postId)
            })
            .disposed(by: disposeBag)
    }
}

enum OWCommentStatusError: Error {
    case processingStatus
}
