//
//  OWRealtimeIndicatorService.swift
//  SpotImCore
//
//  Created by Revital Pisman on 02/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWRealtimeIndicatorServicing {
    var state: Observable<OWRealtimeIndicatorState> { get }
    var realtimeIndicatorType: Observable<OWRealtimeIndicatorType> { get }
    var newComments: Observable<[OWComment]> { get }
    func update(state: OWRealtimeIndicatorState)
    func cleanCache()
}

class OWRealtimeIndicatorService: OWRealtimeIndicatorServicing {

    fileprivate var _shouldRealtimeIndicatorUpdate = BehaviorSubject<OWRealtimeIndicatorState>(value: .disable)
    fileprivate var _newCommentsCache = BehaviorSubject<[String: OWComment]>(value: [:])

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate var spotId: OWSpotId {
        return OWManager.manager.spotId
    }

    fileprivate lazy var isBlitzEnabled: Observable<Bool> = {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: self.spotId)
            .map { [weak self] config -> Bool? in
                return config.mobileSdk.blitzEnabled
            }
            .unwrap()
            .take(1)
            .asObservable()
    }()

    fileprivate lazy var isRealtimeIndicatorEnabled: Observable<Bool> = {
        return _shouldRealtimeIndicatorUpdate
            .withLatestFrom(isBlitzEnabled) { shouldUpdate, isblitzEnabled in
                return isblitzEnabled && shouldUpdate == .enable
            }
            .distinctUntilChanged()
            .asObservable()
            .share()
    }()

    fileprivate lazy var typingCount: Observable<Int> = {
        return realtimeService.realtimeData
            .map { [weak self] realtimeData -> Int? in
                guard let self = self else { return nil }
                return realtimeData.data?.totalTypingCount(forPostId: self.postId)
            }
            .unwrap()
            .distinctUntilChanged()
            .asObservable()
            .share()
    }()

    fileprivate var newCommentsObservable: Observable<[OWComment]> {
        return realtimeService.realtimeData
            .map { [weak self] realtimeData -> [OWComment]? in
                guard let self = self else { return nil }
                return realtimeData.data?.newComments(forPostId: self.postId)
            }
            .unwrap()
            .asObservable()
    }

    var newComments: Observable<[OWComment]> {
        return _newCommentsCache.map { $0.values.map { $0 } }
    }

    lazy var state: Observable<OWRealtimeIndicatorState> = {
        return _shouldRealtimeIndicatorUpdate
            .distinctUntilChanged()
            .asObservable()
            .share()
    }()

    fileprivate lazy var newCommentsCount: Observable<Int> = {
        return newComments.map { $0.count }
    }()

    lazy var realtimeIndicatorType: Observable<OWRealtimeIndicatorType> = {
        return Observable.combineLatest(isRealtimeIndicatorEnabled,
                                        typingCount,
                                        newCommentsCount)
        .map { isEnabled, typingCount, newCommentsCount -> OWRealtimeIndicatorType in
            guard isEnabled else { return .none }

            let updateType: OWRealtimeIndicatorType

            switch (typingCount, newCommentsCount) {
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
        .distinctUntilChanged()
        .asObservable()
        .share()
    }()

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let realtimeService: OWRealtimeServicing
    fileprivate let disposeBag = DisposeBag()

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
        self.realtimeService = servicesProvider.realtimeService()
        self.setupObservers()
    }

    func update(state: OWRealtimeIndicatorState) {
        _shouldRealtimeIndicatorUpdate.onNext(state)
        if state == .disable {
            cleanCache()
        }
    }

    func cleanCache() {
        _newCommentsCache.onNext([:])
    }
}

extension OWRealtimeIndicatorService {
    func setupObservers() {
        newCommentsObservable
            .subscribe(onNext: { [weak self] newComments in
                guard let self = self else { return }

                newComments.forEach { comment in
                    // make sure comment is not reply and not already in conversation
                    guard (comment.parentId == nil || (comment.parentId?.isEmpty) != nil),
                          let commentId = comment.id,
                            (self.servicesProvider.commentsService().get(commentId: commentId, postId: self.postId) == nil) else { return }
                    self.addComment(key: commentId, comment: comment)
                }
            })
            .disposed(by: disposeBag)
    }

    func addComment(key: String, comment: OWComment) {
        guard let currentCache = try? _newCommentsCache.value() else { return }
        var updatedCache = currentCache
        updatedCache[key] = comment
        _newCommentsCache.onNext(updatedCache)
    }
}
