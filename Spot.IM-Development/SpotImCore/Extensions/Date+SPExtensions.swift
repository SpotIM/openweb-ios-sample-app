//
//  Date+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 24/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

extension Date {

    static let dayNameFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()
    
    static let hourFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "HH"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return dateFormatter
    }()

    func timeAgo() -> String {
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
        case (let week, _, _, _, _)     where week > 0:     return formatDate()
        case (_, let day, _, _, _)      where day > 0:      return "\(day)" + LocalizationManager.localizedString(key: "Days")
        case (_, _, let hour, _, _)     where hour > 0:     return "\(hour)" + LocalizationManager.localizedString(key: "Hours")
        case (_, _, _, let minute, _)   where minute > 0:   return "\(minute)" + LocalizationManager.localizedString(key: "Minutes")
        case (_, _, _, _, let second)   where second >= 0:  return LocalizationManager.localizedString(key: "Just now")
        default:                                            return formatDate()
        }
    }
    
    fileprivate func formatDate() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.locale
        let now = Date()
        
        let isInThisYear = calendar.isDate(self, equalTo: now, toGranularity: .year)
        
        if isInThisYear {
            formatter.dateFormat = "d MMM"
        } else {
            formatter.dateFormat = "d MMM, yyyy"
        }
        
        return formatter.string(from: self)
    }

    func seconds(fromDate date: Date) -> Int {

        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: .second, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: .second, in: .era, for: self) else { return 0 }

        return end - start
    }
}
