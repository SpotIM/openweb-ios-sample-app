//
//  SportScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import OpenWebSDK
import Combine

class SportScreenViewModel: ObservableObject {
    private let vertical: ShowcaseVertical = .sport

    private enum MatchConfig {
        static let initialHomeScore = 2
        static let initialAwayScore = 1
        static let initialMinute = 65
        static let startSimulationMinute = 66
        static let finalMinute = 90
        static let tickInterval: TimeInterval = 4
        static let homeGoalProbability = 0.12
        static let awayGoalProbability = 0.24
        static let goalBannerDuration: TimeInterval = 3
    }

    var title: LocalizedStringResource { vertical.title }
    var color: Color { vertical.color }
    var sdkUsageInfo: SDKUsageInfo { vertical.sdkUsageInfo }
    var article: ArticleData { vertical.article }
    var conversationArticle: OWArticleProtocol {
        OWArticle(
            articleInformationStrategy: .server,
            additionalSettings: OWArticleSettings(headerStyle: .none)
        )
    }

    @Published var homeScore = MatchConfig.initialHomeScore
    @Published var awayScore = MatchConfig.initialAwayScore
    @Published var matchMinute = MatchConfig.initialMinute
    @Published var isLive = true
    @Published var goalEvent: GoalEvent?

    private var goalId = 0
    private var matchTimer: AnyCancellable?
    private var goalDismissTimer: AnyCancellable?

    init() {
        startMatch()
    }

    func initialize() {
        // MARK: OpenWeb SDK
        OpenWeb.manager.spotId = article.spotId
        OpenWeb.manager.ui.customizations.customizedTheme.brandColor = OWColor(color)
        OpenWeb.manager.ui.customizations.navigationBarEnforcement = .style(.regular)
    }
}

// MARK: - Private

private extension SportScreenViewModel {
    func startMatch() {
        var currentMinute = MatchConfig.startSimulationMinute
        matchTimer = Timer.publish(every: MatchConfig.tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, currentMinute <= MatchConfig.finalMinute else {
                    self?.matchTimer?.cancel()
                    return
                }

                matchMinute = currentMinute

                let goalRoll = Double.random(in: 0..<1)
                let homeGoal = goalRoll < MatchConfig.homeGoalProbability
                let awayGoal = !homeGoal && goalRoll < MatchConfig.awayGoalProbability

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

                if currentMinute == MatchConfig.finalMinute {
                    isLive = false
                }

                currentMinute += 1
            }
    }

    func dismissGoalAfterDelay() {
        goalDismissTimer?.cancel()
        goalDismissTimer = Just(())
            .delay(for: .seconds(MatchConfig.goalBannerDuration), scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.goalEvent = nil
            }
    }
}
