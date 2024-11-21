//
//  NSRange+Extensions.swift
//  OpenWeb-Development
//
//  Created by Yonat Sharon on 23/11/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

extension NSRange {
    func isCut(by location: Int) -> Bool {
        location > lowerBound && location < upperBound
    }

    mutating func extend(upTo bound: Int) {
        length += bound - upperBound
    }

    mutating func extend(downTo bound: Int) {
        length += lowerBound - bound
        location = bound
    }
}
