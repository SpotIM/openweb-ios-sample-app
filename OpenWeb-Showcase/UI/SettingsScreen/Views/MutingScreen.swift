//
//  MutingScreen.swift
//  OpenWeb-Showcase
//
//  Created by Yonat Sharon on 2026-04-15.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct MutingScreen: View {
    private enum Metrics {
        static let unmuteDelay: Duration = .seconds(0.5)
    }

    @ObservedObject private var provider = ShowcaseScreenConfigurator.mutedUsersProvider
    @State private var showUnmuteAllAlert = false
    @State private var isUnmutingAll = false
    @State private var unmutingUserIds: Set<String> = []

    var body: some View {
        List {
            if provider.mutedUsers.isEmpty {
                Section {
                    Text(.mutingEmptyState)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(.mutingMutedUsersTitle) {
                    ForEach(provider.mutedUsers) { user in
                        mutedUserRow(for: user)
                    }
                    .onDelete { indexSet in
                        let userIdsToUnmute = indexSet.map { index in provider.mutedUsers[index].userId }
                        for userId in userIdsToUnmute {
                            provider.unmute(userId: userId)
                        }
                    }
                }

                Section {
                    if isUnmutingAll {
                        ProgressView()
                    } else {
                        Button(role: .destructive) {
                            showUnmuteAllAlert = true
                        } label: {
                            Text(.mutingUnmuteAllTitle)
                        }
                    }
                }
            }
        }
        .navigationTitle(.settingsMutingTitle)
        .alert(.mutingUnmuteAllAlertTitle, isPresented: $showUnmuteAllAlert) {
            Button(.mutingUnmuteAllAlertCancel, role: .cancel) {}
            Button(.mutingUnmuteAllAlertConfirm, role: .destructive) {
                isUnmutingAll = true
                unmutingUserIds = Set(provider.mutedUsers.map(\.userId))
                Task {
                    try? await Task.sleep(for: Metrics.unmuteDelay)
                    await MainActor.run {
                        provider.unmuteAll()
                        isUnmutingAll = false
                        unmutingUserIds.removeAll()
                    }
                }
            }
        } message: {
            Text(.mutingUnmuteAllAlertMessage)
        }
    }

    @ViewBuilder
    private func mutedUserRow(for user: MutedUserEntry) -> some View {
        HStack {
            Text(user.displayName ?? String(localized: .mutingUnknownUser))
                .font(.bodyText)
            Spacer()
            if unmutingUserIds.contains(user.userId) {
                ProgressView()
            } else {
                Button(.mutingUnmute) {
                    unmutingUserIds.insert(user.userId)
                    Task {
                        try? await Task.sleep(for: Metrics.unmuteDelay)
                        await MainActor.run {
                            provider.unmute(userId: user.userId)
                            unmutingUserIds.remove(user.userId)
                        }
                    }
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.tint)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MutingScreen()
    }
}
