//
//  Font+Extension.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 02/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

// swiftlint:disable no_magic_numbers
extension Font {
    static let screenTitle: Font = .system(size: 20, weight: .bold)
    static let toolbarTitle: Font = .system(size: 18, weight: .bold)
    static let toolbarDescription: Font = .system(size: 12)
    static let sectionTitle: Font = .system(size: 14, weight: .semibold)
    static let bodyText: Font = .system(size: 14)
    static let cardTitle: Font = .system(size: 18, weight: .semibold)
    static let cardDescription: Font = .system(size: 13)
    static let cardIcon: Font = .system(size: 28)
    static let resourceTitle: Font = .subheadline.weight(.semibold)
    static let scoreboardScore: Font = .system(size: 40, weight: .black)
    static let scoreboardLive: Font = .system(size: 11, weight: .heavy)
    static let scoreboardMinute: Font = .system(size: 13, weight: .medium)
    static let scoreboardFullTime: Font = .system(size: 12, weight: .bold)
    static let scoreboardTeamName: Font = .system(size: 14, weight: .bold)
    static let scoreboardGoal: Font = .system(size: 16, weight: .black)
    static let scoreboardGoalEmoji: Font = .system(size: 18)
}
