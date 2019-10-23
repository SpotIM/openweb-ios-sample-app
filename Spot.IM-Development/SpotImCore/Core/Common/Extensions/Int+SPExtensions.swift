//
//  Int+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 18/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var kmFormatted: String {

        let floatValue = CGFloat(self)
        if floatValue >= 1000, floatValue <= 999999 {
            return String(format: "%.1fK",
                          locale: Locale.current,
                          floatValue / 1000).replacingOccurrences(of: ".0", with: "")
        }

        if floatValue > 999999 {
            return String(format: "%.1fM",
                          locale: Locale.current,
                          floatValue / 1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current, floatValue)
    }

    var decimalFormatted: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
