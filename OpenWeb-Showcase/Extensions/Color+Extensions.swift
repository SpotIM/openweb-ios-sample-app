//
//  Color+Extensions.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI

extension Color {
    private struct Metrics {
        static let colorMask: UInt64 = 0xFF
        static let redShift = 16
        static let greenShift = 8
        static let maxColorValue: Double = 255
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> Metrics.redShift) & Metrics.colorMask) / Metrics.maxColorValue,
            green: Double((rgb >> Metrics.greenShift) & Metrics.colorMask) / Metrics.maxColorValue,
            blue: Double(rgb & Metrics.colorMask) / Metrics.maxColorValue
        )
    }

    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return String(format: "#%02X%02X%02X", Int(red * Metrics.maxColorValue), Int(green * Metrics.maxColorValue), Int(blue * Metrics.maxColorValue))
    }
}
