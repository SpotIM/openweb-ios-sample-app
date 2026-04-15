//
//  ShowcaseMutedUsersProvider.swift
//  OpenWeb-Showcase
//
//  Created by Yonat Sharon on 2026-04-15.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import Combine
import Foundation
@_spi(Muting) import OpenWebSDK

struct MutedUserEntry: Codable, Identifiable, Hashable {
    var userId: String
    var displayName: String?
    var id: String { userId }
}

final class ShowcaseMutedUsersProvider: ObservableObject, OWMutedUsersProviding {
    private enum Keys {
        static let mutedUsers = "showcase.mutedUsers"
    }

    @Published private(set) var mutedUsers: [MutedUserEntry] = []

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        mutedUsers = loadFromDefaults()
    }

    func mutedUserIds() -> Set<String> {
        Set(mutedUsers.map(\.userId))
    }

    func muteUser(userId: String, displayName: String?) {
        guard !mutedUsers.contains(where: { $0.userId == userId }) else { return }
        mutedUsers.append(MutedUserEntry(userId: userId, displayName: displayName))
        persist()
    }

    func unmute(userId: String) {
        mutedUsers.removeAll { $0.userId == userId }
        persist()
    }

    func unmuteAll() {
        mutedUsers.removeAll()
        persist()
    }

    var muteConfirmationMessage: String? {
        String(localized: .mutingMuteConfirmationMessage)
    }
}

private extension ShowcaseMutedUsersProvider {
    func persist() {
        guard let data = try? JSONEncoder().encode(mutedUsers) else { return }
        defaults.set(data, forKey: Keys.mutedUsers)
    }

    func loadFromDefaults() -> [MutedUserEntry] {
        guard let data = defaults.data(forKey: Keys.mutedUsers),
              let decoded = try? JSONDecoder().decode([MutedUserEntry].self, from: data) else {
            return []
        }
        return decoded
    }
}
