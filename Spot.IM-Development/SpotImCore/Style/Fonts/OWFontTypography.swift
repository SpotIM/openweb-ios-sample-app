//
//  OWFontTypography.swift
//  SpotImCore
//
//  Created by Revital Pisman on 09/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

enum OWFontTypography {
    /// T3 (B)
    case titleSmall
    /// T1 (B)
    case titleLarge
    /// T2 (B)
    case titleMedium
    /// T2 (I)
    case titleMediumSpecial
    /// T4
    case bodyText
    /// T4 (SB)
    case bodyInteraction
    /// T4 (B)
    case bodyContext
    /// T4 (I)
    case bodySpecial
    /// T5
    case footnoteText
    /// T5 (SB)
    case footnoteLink
    /// T5 (B)
    case footnoteContext
    /// T5 (I)
    case footnoteSpecial
    /// T6
    case metaText
    /// T7
    case infoText
}

extension OWFontTypography {

    var defaultSize: CGFloat {
        switch self {
        case .titleLarge: return 24
        case .titleMedium: return 20
        case .titleMediumSpecial: return 20
        case .titleSmall: return 18
        case .bodyText: return 15
        case .bodyInteraction: return 15
        case .bodyContext: return 15
        case .bodySpecial: return 15
        case .footnoteText: return 13
        case .footnoteLink: return 13
        case .footnoteContext: return 13
        case .footnoteSpecial: return 13
        case .metaText: return 12
        case .infoText: return 10
        }
    }

    var fontStyle: OWFontStyle {
        switch self {
        case .titleLarge: return .bold
        case .titleMedium: return .bold
        case .titleMediumSpecial: return .italic
        case .titleSmall: return .bold
        case .bodyText: return .regular
        case .bodyInteraction: return .semiBold
        case .bodyContext: return .bold
        case .bodySpecial: return .italic
        case .footnoteText: return .regular
        case .footnoteLink: return .semiBold
        case .footnoteContext: return .bold
        case .footnoteSpecial: return .italic
        case .metaText: return .regular
        case .infoText: return .semiBold
        }
    }

    var textStyle: UIFont.TextStyle {
        switch self {
        case .titleLarge: return .title2
        case .titleMedium: return .title3
        case .titleMediumSpecial: return .title3
        case .titleSmall: return .headline
        case .bodyText: return .body
        case .bodyInteraction: return .body
        case .bodyContext: return .body
        case .bodySpecial: return .body
        case .footnoteText: return .footnote
        case .footnoteLink: return .footnote
        case .footnoteContext: return .footnote
        case .footnoteSpecial: return .footnote
        case .metaText: return .caption1
        case .infoText: return .caption2
        }
    }

    var maxSizeEnforcement: OWFontSizeEnforcement {
        switch self {
        case .titleLarge: return .fixed(26)
        case .titleMedium: return .fixed(24)
        case .titleMediumSpecial: return .fixed(24)
        case .titleSmall: return .fixed(21)
        case .bodyText: return .fixed(21)
        case .bodyInteraction: return .fixed(21)
        case .bodyContext: return .fixed(21)
        case .bodySpecial: return .fixed(21)
        case .footnoteText: return .fixed(17)
        case .footnoteLink: return .fixed(17)
        case .footnoteContext: return .fixed(17)
        case .footnoteSpecial: return .fixed(17)
        case .metaText: return .fixed(16)
        case .infoText: return .fixed(15)
        }
    }

    var minSizeEnforcement: OWFontSizeEnforcement {
        switch self {
        case .titleLarge: return .none
        case .titleMedium: return .none
        case .titleMediumSpecial: return .none
        case .titleSmall: return .none
        case .bodyText: return .none
        case .bodyInteraction: return .none
        case .bodyContext: return .none
        case .bodySpecial: return .none
        case .footnoteText: return .none
        case .footnoteLink: return .none
        case .footnoteContext: return .none
        case .footnoteSpecial: return .none
        case .metaText: return .none
        case .infoText: return .none
        }
    }
}
