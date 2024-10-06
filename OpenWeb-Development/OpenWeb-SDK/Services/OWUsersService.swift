//
//  OWUsersService.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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
    private var disposeBag = DisposeBag()
    private unowned let servicesProvider: OWSharedServicesProviding

    // Multiple threads / queues access to this class
    // Avoiding "data race" by using a lock
    private let lock: OWLock = OWUnfairLock()

    private var _users = OWUsersMapper()

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }

    func get(userId id: String) -> SPUser? {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks
        guard let user = _users[id] else { return nil }
        return user
    }

    func set(users: [SPUser]) {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        let userIdToUserTupples: [(String, SPUser)] = users.map {
            guard let id = $0.id else { return nil }
            return (id, $0)
        }.unwrap()
        let userIdsToUser: OWUsersMapper = userIdToUserTupples.reduce(into: [:]) { $0[$1.0] = $1.1 }

        // merge and replacing current users
        _users.merge(userIdsToUser, uniquingKeysWith: { _, new in new })
    }

    func set(users: OWUsersMapper) {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        // merge and replacing current users
        _users.merge(users, uniquingKeysWith: { _, new in new })
    }

    func cleanCache() {
        // swiftlint:disable self_capture_in_blocks
        self.lock.lock(); defer { self.lock.unlock() }
        // swiftlint:enable self_capture_in_blocks

        _users.removeAll()
    }

    func isUserOnline(_ userId: String, perPostId postId: OWPostId, realtimeData: OWRealTimeData) -> Bool {
        return realtimeData.onlineUsers(forPostId: postId).contains { $0.userId == userId }
    }
}

private extension OWUsersService {
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
                guard let self else { return }
                self.set(users: [user])
            })
            .disposed(by: disposeBag)
    }
}
