//
//  OWUsersService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

typealias OWUsersMapper = [String: SPUser]

protocol OWUsersServicing {
    func get(userId id: String) -> SPUser?
    func set(users: OWUsersMapper)
    func set(users: [SPUser])
    func isUserOnline(_ userId: String, perPostId postId: OWPostId, realtimeData: OWRealTimeData) -> Bool

    func cleanCache()
}

class OWUsersService: OWUsersServicing {
    fileprivate var disposeBag = DisposeBag()
    fileprivate unowned let servicesProvider: OWSharedServicesProviding

    // Multiple threads / queues access to this class
    // Avoiding "data race" by using a lock
    fileprivate let lock: OWLock = OWUnfairLock()

    fileprivate var _users = OWUsersMapper()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }

    func get(userId id: String) -> SPUser? {
        self.lock.lock(); defer { self.lock.unlock() }

        guard let user = _users[id] else { return nil }
        return user
    }

    func set(users: [SPUser]) {
        self.lock.lock(); defer { self.lock.unlock() }

        let userIdToUserTupples: [(String, SPUser)] = users.map {
            guard let id = $0.id else { return nil }
            return (id, $0)
        }.unwrap()
        let userIdsToUser: OWUsersMapper = Dictionary(uniqueKeysWithValues: userIdToUserTupples)

        // merge and replacing current users
        _users.merge(userIdsToUser, uniquingKeysWith: {(_, new) in new })
    }

    func set(users: OWUsersMapper) {
        self.lock.lock(); defer { self.lock.unlock() }

        // merge and replacing current users
        _users.merge(users, uniquingKeysWith: {(_, new) in new })
    }

    func cleanCache() {
        self.lock.lock(); defer { self.lock.unlock() }

        _users.removeAll()
    }

    func isUserOnline(_ userId: String, perPostId postId: OWPostId, realtimeData: OWRealTimeData) -> Bool {
        return realtimeData.onlineUsers(forPostId: postId).contains { $0.userId == userId }
    }
}

fileprivate extension OWUsersService {
    func setupObservers() {
        self.servicesProvider.authenticationManager()
            .activeUserAvailability
            .map { availability -> SPUser? in
                switch availability {
                case .notAvailable:
                    return nil
                case .user(let user):
                    return user
                }
            }
            .unwrap()
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.set(users: [user])
            })
            .disposed(by: disposeBag)
    }
}
