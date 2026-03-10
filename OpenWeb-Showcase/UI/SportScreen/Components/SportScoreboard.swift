//
//  SportScoreboard.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 10/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

struct GoalEvent: Equatable {
    var teamName: String
    var id: Int
}

struct SportScoreboard: View {
    private struct Metrics {
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 8
        static let statusBarBackgroundOpacity: CGFloat = 0.2
        static let liveDotSize: CGFloat = 6
        static let livePillHorizontalPadding: CGFloat = 10
        static let livePillVerticalPadding: CGFloat = 3
        static let teamsHorizontalPadding: CGFloat = 24
        static let teamsVerticalPadding: CGFloat = 20
        static let logoSize: CGFloat = 72
        static let logoImageSize: CGFloat = 52
        static let logoBorderWidth: CGFloat = 2
        static let logoBorderOpacity: CGFloat = 0.6
        static let logoGlowRadius: CGFloat = 10
        static let logoGlowOpacity: CGFloat = 0.15
        static let teamNameSpacing: CGFloat = 10
        static let goalBannerVerticalPadding: CGFloat = 10
        static let goalScaleTarget: CGFloat = 1.5
    }

    var homeTeamName: String = "Home Team" // TODO: localize
    var homeTeamLogo: String = "team_logo_home"
    var homeScore: Int = 2
    var awayTeamName: String = "Away Team" // TODO: localize
    var awayTeamLogo: String = "team_logo_away"
    var awayScore: Int = 1
    var matchMinute: Int = 0
    var isLive: Bool = true
    var goalEvent: GoalEvent?
    var brandColor: Color = Color(.sport)

    @State private var homeScoreScale: CGFloat = 1
    @State private var awayScoreScale: CGFloat = 1
    @State private var homeScoreHighlighted = false
    @State private var awayScoreHighlighted = false
    @State private var showGoalBanner = false

    var body: some View {
        VStack(spacing: 0) {
            statusBar
            teamsAndScores
            goalBanner
        }
        .clipShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
        .padding(.horizontal, Metrics.horizontalPadding)
        .padding(.vertical, Metrics.verticalPadding)
        .onChange(of: goalEvent) { newEvent in
            handleGoalEvent(newEvent)
        }
    }
}

// MARK: - Subviews

private extension SportScoreboard {
    var statusBar: some View {
        ZStack {
            Color.black.opacity(Metrics.statusBarBackgroundOpacity)
            if isLive {
                liveIndicator
            } else {
                fullTimeIndicator
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 30)
    }

    var liveIndicator: some View {
        HStack(spacing: 8) {
            livePill
            Text("· \(matchMinute)'")
                .font(.scoreboardMinute)
                .foregroundStyle(.white)
        }
    }

    var livePill: some View {
        HStack(spacing: 5) {
            PulsingDot(size: Metrics.liveDotSize)
            Text("LIVE")
                .font(.scoreboardLive)
                .foregroundStyle(.white)
                .tracking(1)
        }
        .padding(.horizontal, Metrics.livePillHorizontalPadding)
        .padding(.vertical, Metrics.livePillVerticalPadding)
        .background(Color(red: 1.0, green: 0.23, blue: 0.19))
        .clipShape(Capsule())
    }

    var fullTimeIndicator: some View {
        Text("FULL TIME")
            .font(.scoreboardFullTime)
            .foregroundStyle(.white)
            .tracking(1.5)
    }

    var teamsAndScores: some View {
        HStack {
            teamView(name: homeTeamName, logo: homeTeamLogo)
                .frame(maxWidth: .infinity)
            scoreView
                .frame(maxWidth: .infinity)
            teamView(name: awayTeamName, logo: awayTeamLogo)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Metrics.teamsHorizontalPadding)
        .padding(.vertical, Metrics.teamsVerticalPadding)
        .background(brandColor)
    }

    var scoreView: some View {
        HStack(spacing: 0) {
            Text("\(homeScore)")
                .foregroundStyle(homeScoreHighlighted ? .yellow : .white)
                .scaleEffect(homeScoreScale)
            Text(" - ")
                .foregroundStyle(.white.opacity(0.5))
            Text("\(awayScore)")
                .foregroundStyle(awayScoreHighlighted ? .yellow : .white)
                .scaleEffect(awayScoreScale)
        }
        .font(.scoreboardScore)
    }

    func teamView(name: String, logo: String) -> some View {
        VStack(spacing: Metrics.teamNameSpacing) {
            teamLogo(logo)
            Text(name)
                .font(.scoreboardTeamName)
                .foregroundStyle(.white)
                .lineLimit(1)
                .shadow(color: .black.opacity(0.4), radius: 3, x: 1, y: 1)
        }
    }

    func teamLogo(_ logo: String) -> some View {
        ZStack {
            Circle()
                .fill(.white.opacity(Metrics.logoGlowOpacity))
                .frame(
                    width: Metrics.logoSize + Metrics.logoGlowRadius * 2,
                    height: Metrics.logoSize + Metrics.logoGlowRadius * 2
                )
            Circle()
                .fill(.white)
                .frame(width: Metrics.logoSize, height: Metrics.logoSize)
                .overlay(
                    Circle()
                        .stroke(.white.opacity(Metrics.logoBorderOpacity), lineWidth: Metrics.logoBorderWidth)
                )
                .shadow(radius: 6)
                .overlay {
                    Image(logo)
                        .squareFrame(size: Metrics.logoImageSize)
                }
        }
    }

    @ViewBuilder
    var goalBanner: some View {
        if showGoalBanner {
            HStack(spacing: 8) {
                Text("⚽")
                    .font(.scoreboardGoalEmoji)
                Text("GOAL!")
                    .font(.scoreboardGoal)
                    .foregroundStyle(.yellow)
                    .tracking(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Metrics.goalBannerVerticalPadding)
            .background(brandColor.overlay(Color.black.opacity(Metrics.statusBarBackgroundOpacity)))
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
}

// MARK: - Goal Animation

private extension SportScoreboard {
    func handleGoalEvent(_ event: GoalEvent?) {
        guard let event else {
            withAnimation { showGoalBanner = false }
            homeScoreHighlighted = false
            awayScoreHighlighted = false
            return
        }

        let isHome = event.teamName == homeTeamName
        if isHome {
            homeScoreHighlighted = true
        } else {
            awayScoreHighlighted = true
        }

        withAnimation { showGoalBanner = true }

        withAnimation(.easeOut(duration: 0.2)) {
            if isHome { homeScoreScale = Metrics.goalScaleTarget }
            else { awayScoreScale = Metrics.goalScaleTarget }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.2)) {
                if isHome { homeScoreScale = 1 }
                else { awayScoreScale = 1 }
            }
        }
    }
}

// MARK: - Pulsing Dot

private struct PulsingDot: View {
    var size: CGFloat

    @State private var opacity: CGFloat = 1

    var body: some View {
        Circle()
            .fill(.white.opacity(opacity))
            .frame(width: size, height: size)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 0.3
                }
            }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SportScoreboard()
        SportScoreboard(
            homeScore: 3, awayScore: 2,
            matchMinute: 90, isLive: false
        )
    }
}
