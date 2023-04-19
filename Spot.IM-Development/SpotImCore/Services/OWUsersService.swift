//
//  OWUsersService.swift
//  SpotImCore
//
//  Created by Alon Shprung on 19/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

internal protocol OWUsersServicing {
    func getUser(with id: String) -> SPUser?
    func setUsers(_ users: [String: SPUser])
    func setUsers(_ users: [SPUser])

    func cleanCachedUsers()
}

class OWUsersService: OWUsersServicing {

    private var _users = [String: SPUser]()

    func getUser(with id: String) -> SPUser? {
        guard let user = _users[id] else { return nil }
        return user
    }

    func setUsers(_ users: [SPUser]) {
        let userIdsToUser: [String: SPUser] = Dictionary(uniqueKeysWithValues: users.map { ($0.id!, $0) })

        // merge and replacing current users
        _users.merge(userIdsToUser, uniquingKeysWith: {(_, new) in new })
    }

    func setUsers(_ users: [String: SPUser]) {
        // merge and replacing current users
        _users.merge(users, uniquingKeysWith: {(_, new) in new })
    }

    func cleanCachedUsers() {
        _users.removeAll()
    }
}
