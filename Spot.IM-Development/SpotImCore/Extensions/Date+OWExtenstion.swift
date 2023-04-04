//
//  Date+OWExtenstion.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 04/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

extension Date {

    static let owDayNameFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"
        dateFormatter.locale = OWLocalizationManager.shared.locale

        return dateFormatter
    }()

    static let owHourFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "HH"
        dateFormatter.locale = OWLocalizationManager.shared.locale

        return dateFormatter
    }()

    func owTimeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest = self > now ? self : now

        let unitFlags: Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfYear]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        let weekOfYear = components.weekOfYear ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        switch (weekOfYear, day, hour, minute, second) {
        case (let week, _, _, _, _)     where week > 0:     return owFormatDate()
        case (_, let day, _, _, _)      where day > 0:      return "\(day)" + OWLocalizationManager.shared.localizedString(key: "Days")
        case (_, _, let hour, _, _)     where hour > 0:     return "\(hour)" + OWLocalizationManager.shared.localizedString(key: "Hours")
        case (_, _, _, let minute, _)   where minute > 0:   return "\(minute)" + OWLocalizationManager.shared.localizedString(key: "Minutes")
        case (_, _, _, _, let second)   where second >= 0:  return OWLocalizationManager.shared.localizedString(key: "Just now")
        default:                                            return owFormatDate()
        }
    }

    fileprivate func owFormatDate() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = OWLocalizationManager.shared.locale
        let now = Date()

        let isInThisYear = calendar.isDate(self, equalTo: now, toGranularity: .year)

        if isInThisYear {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM, yyyy"
        }

        return formatter.string(from: self)
    }
}
