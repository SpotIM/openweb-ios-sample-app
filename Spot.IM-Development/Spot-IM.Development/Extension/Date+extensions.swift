//
//  Date+extensions.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 15/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

public extension Date {

    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now

        let unitFlags: Set<Calendar.Component> = [.second, .minute, .hour, .day, .weekOfYear]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)

        let weekOfYear = components.weekOfYear ?? 0
        let day = components.day ?? 0
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        switch (weekOfYear, day, hour, minute, second) {
        case (let week, _, _, _, _)     where week > 0:     return formatDate()
        case (_, let day, _, _, _)      where day > 0:      return "\(day)d ago"
        case (_, _, let hour, _, _)     where hour > 0:     return "\(hour)h ago"
        case (_, _, _, let minute, _)   where minute > 0:   return "\(minute)m ago"
        case (_, _, _, _, let second)   where second > 0:   return "Just now"
        default:                                            return formatDate()
        }
    }

    fileprivate func formatDate() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
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
