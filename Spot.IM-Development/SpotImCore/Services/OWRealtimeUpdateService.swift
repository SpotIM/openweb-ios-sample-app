//
//  OWRealtimeUpdateService.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWRealtimeUpdateServicing {
    var shouldRealtimeUpdate: BehaviorSubject<OWRealtimeUpdateState> { get } // TODO change to func
    var realtimeUpdateType: Observable<OWRealtimeIndicatorType> { get }
    var newComments: Observable<[OWComment]> { get }
}

class OWRealtimeUpdateService: OWRealtimeUpdateServicing {

    var shouldRealtimeUpdate = BehaviorSubject<OWRealtimeUpdateState>(value: .disable)

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate var spotId: OWSpotId {
        return OWManager.manager.spotId
    }

    fileprivate lazy var typingCount: Observable<Int> = {
        return realtimeService.realtimeData
            .map { [weak self] realtimeData -> Int? in
                guard let self = self else { return nil }
                return try? realtimeData.data?.totalTypingCount(forConversation: "\(self.spotId)_\(self.postId)")
            }
            .unwrap()
            .distinctUntilChanged()
            .debug("RIVI: typingCount")
            .asObservable()
            .share()
    }()

    lazy var newComments: Observable<[OWComment]> = {
        return realtimeService.realtimeData
            .map { [weak self] realtimeData -> [OWComment]? in
                guard let self = self else { return nil }
                return try? realtimeData.data?.newComments(forConversation: ("\(self.spotId)_\(self.postId)"))
            }
            .unwrap()
            .debug("RIVI: newComments")
            .asObservable()
            .share()
    }()

    fileprivate lazy var newCommentsCount: Observable<Int> = {
        return newComments
            .map { $0.count }
            .distinctUntilChanged()
            .debug("RIVI: newCommentsCount")
            .asObservable()
            .share()
    }()

    fileprivate lazy var isRealtimeIndicatorEnabled: Observable<Bool> = {
        // Fetch the spot configuration
        let spotConfigurationObservable = servicesProvider.spotConfigurationService()
            .config(spotId: self.spotId)

        return shouldRealtimeUpdate
            .withLatestFrom(spotConfigurationObservable) { shouldUpdate, config in
                return (shouldUpdate, config)
            }
            .map { shouldUpdate, config in
                guard let blitzEnabled = config.mobileSdk.blitzEnabled, shouldUpdate == .enable else { return false }
                return blitzEnabled //TODO: blitzEnabled
            }
            .debug("RIVI: isRealtimeIndicatorEnabled")
            .asObservable()
    }()

    var realtimeUpdateType: Observable<OWRealtimeIndicatorType> {
        return Observable.combineLatest(isRealtimeIndicatorEnabled,
                                        typingCount,
                                        newCommentsCount)
        .map { isEnabled, typingCount, newCommentsCount in
            guard isEnabled else { return .none }

            let updateType: OWRealtimeIndicatorType

            switch (typingCount, newCommentsCount) { //TODO: (typingCount, newCommentsCount)
            case let (typing, comments) where typing > 0 && comments > 0:
                updateType = .all(typingCount: typing, newCommentsCount: comments)
            case let (typing, _) where typing > 0:
                updateType = .typing(count: typing)
            case let (_, comments) where comments > 0:
                updateType = .newComments(count: comments)
            default:
                updateType = .none
            }

            return updateType
        }
        .debug("RIVI realtimeUpdateType")
        .asObservable()
        .share()
    }

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let realtimeService: OWRealtimeServicing

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
        self.realtimeService = servicesProvider.realtimeService()
    }
}
