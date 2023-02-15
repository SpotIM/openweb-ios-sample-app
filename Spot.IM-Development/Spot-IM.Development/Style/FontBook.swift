//
//  FontBook.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

// Internal fonts inside the SampleApp.
// We might configure the font family in the future, but for now for the internal SampleApp it's good enough.

class FontBook {
    static let primaryHeading = font(with: .regular, size: 30)
    static let primaryHeadingBold = font(with: .bold, size: 30)
    static let primaryHeadingMedium = font(with: .medium, size: 30)
    static let primaryHeadingLight = font(with: .light, size: 30)

    static let mainHeading = font(with: .regular, size: 20)
    static let mainHeadingBold = font(with: .bold, size: 24)
    static let mainHeadingMedium = font(with: .medium, size: 24)
    static let mainHeadingLight = font(with: .light, size: 24)

    static let secondaryHeading = font(with: .regular, size: 20)
    static let secondaryHeadingBold = font(with: .bold, size: 20)
    static let secondaryHeadingMedium = font(with: .medium, size: 20)
    static let secondaryHeadingLight = font(with: .light, size: 20)

    static let paragraph = font(with: .regular, size: 16)
    static let paragraphBold = font(with: .bold, size: 16)
    static let paragraphMedium = font(with: .medium, size: 16)
    static let paragraphLight = font(with: .light, size: 16)

    static let helper = font(with: .regular, size: 14)
    static let helperBold = font(with: .bold, size: 14)
    static let helperMedium = font(with: .medium, size: 14)
    static let helperLight = font(with: .light, size: 14)
}

fileprivate extension FontBook {
    static func font(with type: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: type.fontName, size: size)!
    }
}

fileprivate enum FontType {
    case regular, medium, bold, light

    var fontName: String {
        switch self {
        case .regular:
            return "HelveticaNeue"
        case .medium:
            return "HelveticaNeue-Medium"
        case .bold:
            return "HelveticaNeue-Bold"
        case .light:
            return "HelveticaNeue-Light"
        }
    }
}
