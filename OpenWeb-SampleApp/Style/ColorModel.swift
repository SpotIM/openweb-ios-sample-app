//
//  Colors.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 18/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit

struct ColorModel {
    var color: UIColor

    enum ColorType: CaseIterable {
        case background
        case text
        case blue
        case blackish
        case darkGrey
        case basicGrey
        case midGrey
        case lightGrey
        case extraLightGrey
        case red
        case orange
        case green
        case purple
        case pink
        case highlightBlue
        case white

        var `default`: ColorModel {
            switch self {
            case .background:
                return ColorModel(color: .systemBackground)
            case .text:
                return ColorModel(color: .label)
            case .blue:
                return ColorModel(color: UIColor(r: 39, g: 120, b: 206))
            case .blackish:
                return ColorModel(color: UIColor(r: 51, g: 51, b: 51))
            case .darkGrey:
                return ColorModel(color: UIColor(r: 128, g: 128, b: 128))
            case .basicGrey:
                return ColorModel(color: UIColor(r: 196, g: 196, b: 196))
            case .midGrey:
                return ColorModel(color: UIColor(r: 225, g: 225, b: 225))
            case .lightGrey:
                return ColorModel(color: UIColor(r: 241, g: 241, b: 241))
            case .extraLightGrey:
                return ColorModel(color: UIColor(r: 247, g: 247, b: 247))
            case .red:
                return ColorModel(color: UIColor(r: 228, g: 66, b: 88))
            case .orange:
                return ColorModel(color: UIColor(r: 255, g: 172, b: 44))
            case .green:
                return ColorModel(color: UIColor(r: 0, g: 202, b: 114))
            case .purple:
                return ColorModel(color: UIColor(r: 163, g: 88, b: 223))
            case .pink:
                return ColorModel(color: UIColor(r: 246, g: 95, b: 124))
            case .highlightBlue:
                return ColorModel(color: UIColor(r: 204, g: 233, b: 255))
            case .white:
                return ColorModel(color: .white)
            }
        }
    }
}

extension ColorModel {
    func color(forThemeStyle style: ThemeStyle) -> UIColor {
        color
    }
}
