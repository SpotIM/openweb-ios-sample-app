//
//  DispatchTime+Utils.swift
//  OpenWebSDK
//
//  Created by Yonat Sharon on 10/11/2024.
//

import Foundation

extension DispatchTime {
    func timeInterval(to endTime: DispatchTime) -> TimeInterval {
        if #available(iOS 13.0, *) {
            return distance(to: endTime).timeInterval
        } else {
            let timeDiff = rawValue - endTime.rawValue
            return Double(timeDiff / USEC_PER_SEC) / Double(NSEC_PER_USEC)
        }
    }
}

extension DispatchTimeInterval {
    var timeInterval: TimeInterval {
        switch self {
        case .seconds(let seconds):
            return TimeInterval(seconds)
        case .milliseconds(let milliseconds):
            return TimeInterval(milliseconds) / 1_000
        case .microseconds(let microseconds):
            return TimeInterval(microseconds) / 1_000_000
        case .nanoseconds(let nanoseconds):
            return TimeInterval(nanoseconds) / 1_000_000_000
        case .never:
            return 0
        @unknown default:
            return 0
        }
    }
}
