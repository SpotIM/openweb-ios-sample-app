//
//  OWFilterTabsDictateService.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 05/06/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWFilterTabsDictateServicing {
    func filterId(perPostId postId: OWPostId) -> Observable<OWFilterTabId>
    func update(filterTabId: OWFilterTabId, for postId: OWPostId)
    func invalidateCache()
}

class OWFilterTabsDictateService: OWFilterTabsDictateServicing {
    fileprivate typealias OWSkipAndMapping = Observable<(Bool, [OWPostId: OWFilterTabId])>
    fileprivate unowned let servicesProvider: OWSharedServicesProviding

    fileprivate let mapper = BehaviorSubject<[OWPostId: OWFilterTabId]>(value: [:])
    fileprivate lazy var sharedMapper = {
        return mapper
            .share(replay: 1)
            .observe(on: MainScheduler.instance)
    }()

    init (servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
    }

    func filterId(perPostId postId: OWPostId) -> Observable<OWFilterTabId> {
        return mapper
            .take(1)
            .flatMap { mapping -> OWSkipAndMapping in
                // 1. Check if we already have a filter tab id for the postId in the mapper

                guard let _ = mapping[postId] else {
                    return Observable.just((false, mapping))
                }

                // We already have a mapping for the required filtering option for this postId, skip to next step
                return Observable.just((true, mapping))
            }
            .do(onNext: { [weak self] skipAndMapper in
                // 2. Inject sort option to the mapper from local or from server config according to `OWInitialSortStrategy`

                guard let self = self else { return }
                let shouldSkip = skipAndMapper.0
                let mapping = skipAndMapper.1

                if !shouldSkip {
                    // We will inject to the mapper the required initial filter tab id
                    self.inject(toPostId: postId, filterTabId: OWFilterTabObject.defaultTabId, fromOriginalMapping: mapping)
                }
            })
            .flatMap { [weak self] _ -> Observable<[OWPostId: OWFilterTabId]> in
                // 3. Returning sharedMapper after we sure there is a filter tab id for the postId

                guard let self = self else { return .empty() }
                return self.sharedMapper
            }
            .map { [weak self] mapping -> OWFilterTabId in
                // 4. Mapping to the appropriate filter tab id per postId

                guard let self = self else { return OWFilterTabObject.defaultTabId }
                guard let filterTabId = mapping[postId] else {
                    // This should never happen
                    let logMessage = "Failed to get the appropriate filter tab option for postId: \(postId), recovering by passing `default` "
                    self.servicesProvider.logger().log(level: .error, logMessage)
                    return OWFilterTabObject.defaultTabId
                }

                return filterTabId
            }
            .distinctUntilChanged()
        }

    func update(filterTabId: OWFilterTabId, for postId: OWPostId) {
        _ = mapper
            .take(1)
            .subscribe(onNext: { [weak self] mapping in
                guard let self = self else { return }
                self.inject(toPostId: postId, filterTabId: filterTabId, fromOriginalMapping: mapping)
            })
    }

    func invalidateCache() {
        mapper.onNext([:])
    }
}

fileprivate extension OWFilterTabsDictateService {
    func inject(toPostId postId: OWPostId,
                filterTabId: OWFilterTabId,
                fromOriginalMapping originalMapping: [OWPostId: OWFilterTabId]) {
        var newMapping = originalMapping
        newMapping[postId] = filterTabId
        self.mapper.onNext(newMapping)
    }
}
