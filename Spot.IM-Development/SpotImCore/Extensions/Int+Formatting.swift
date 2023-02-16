//
//  Int+Formatting.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/9/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

extension Int {

    static let commasFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        return formatter
    }()

    func formatedCount() -> String {
        let formattedNumber = Int.commasFormatter.string(from: NSNumber(value: self))

        return formattedNumber ?? "\(self)"
    }
}
