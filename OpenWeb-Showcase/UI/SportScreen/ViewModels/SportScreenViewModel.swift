//
//  SportScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

// swiftlint:disable no_magic_numbers
class SportScreenViewModel: ObservableObject {
    let title: LocalizedStringResource = "verticalSportTitle"

    @Published var homeScore = 2
    @Published var awayScore = 1
    @Published var matchMinute = 65
    @Published var isLive = true
    @Published var goalEvent: GoalEvent?

    private var goalId = 0
    private var matchTimer: AnyCancellable?
    private var goalDismissTimer: AnyCancellable?

    init() {
        startMatch()
    }
}

// MARK: - Private

private extension SportScreenViewModel {
    func startMatch() {
        var currentMinute = 66
        matchTimer = Timer.publish(every: 4, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, currentMinute <= 90 else {
                    self?.matchTimer?.cancel()
                    return
                }

                matchMinute = currentMinute

                let goalRoll = Double.random(in: 0..<1)
                let homeGoal = goalRoll < 0.12
                let awayGoal = !homeGoal && goalRoll < 0.24

                if homeGoal {
                    goalId += 1
                    homeScore += 1
                    goalEvent = GoalEvent(team: .home, id: goalId)
                    dismissGoalAfterDelay()
                }

                if awayGoal {
                    goalId += 1
                    awayScore += 1
                    goalEvent = GoalEvent(team: .away, id: goalId)
                    dismissGoalAfterDelay()
                }

                if currentMinute == 90 {
                    isLive = false
                }

                currentMinute += 1
            }
    }

    func dismissGoalAfterDelay() {
        goalDismissTimer?.cancel()
        goalDismissTimer = Just(())
            .delay(for: .seconds(3), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.goalEvent = nil
            }
    }
}
