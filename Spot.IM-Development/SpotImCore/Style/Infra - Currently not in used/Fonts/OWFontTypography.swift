//
//  OWFontTypography.swift
//  SpotImCore
//
//  Created by Revital Pisman on 09/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

enum OWFontTypography {
    case titleSmall
    case titleLarge
    case titleMedium
    case bodyText
    case bodyInteraction
    case bodyContext
    case bodySpecial
    case footnoteText
    case footnoteLink
    case footnoteContext
    case footnoteSpecial
    case footnoteCaption
    case metaText
    case infoCaption

    var defaultSize: CGFloat {
        switch self {
        case .titleLarge: return 24
        case .titleMedium: return 20
        case .titleSmall: return 18
        case .bodyText: return 15
        case .bodyInteraction: return 15
        case .bodyContext: return 15
        case .bodySpecial: return 15
        case .footnoteText: return 13
        case .footnoteLink: return 13
        case .footnoteContext: return 13
        case .footnoteSpecial: return 13
        case .footnoteCaption: return 13
        case .metaText: return 12
        case .infoCaption: return 10
        }
    }

    var fontStyle: OWFontStyle {
        switch self {
        case .titleLarge: return .bold
        case .titleMedium: return .bold
        case .titleSmall: return .bold
        case .bodyText: return .regular
        case .bodyInteraction: return .semiBold
        case .bodyContext: return .bold
        case .bodySpecial: return .italic
        case .footnoteText: return .regular
        case .footnoteLink: return .semiBold
        case .footnoteContext: return .bold
        case .footnoteSpecial: return .italic
        case .footnoteCaption: return .regular
        case .metaText: return .regular
        case .infoCaption: return .semiBold
        }
    }

    var textStyle: UIFont.TextStyle {
        switch self {
        case .titleLarge: return .title2
        case .titleMedium: return .title3
        case .titleSmall: return .headline
        case .bodyText: return .body
        case .bodyInteraction: return .body
        case .bodyContext: return .body
        case .bodySpecial: return .body
        case .footnoteText: return .footnote
        case .footnoteLink: return .footnote
        case .footnoteContext: return .footnote
        case .footnoteSpecial: return .footnote
        case .footnoteCaption: return .footnote
        case .metaText: return .caption1
        case .infoCaption: return .caption2
        }
    }

    var maxSizeEnforcement: OWFontSizeEnforcement {
        switch self {
        case .titleLarge: return .fixed(26)
        case .titleMedium: return .fixed(24)
        case .titleSmall: return .fixed(21)
        case .bodyText: return .fixed(21)
        case .bodyInteraction: return .fixed(21)
        case .bodyContext: return .fixed(21)
        case .bodySpecial: return .fixed(21)
        case .footnoteText: return .fixed(17)
        case .footnoteLink: return .fixed(17)
        case .footnoteContext: return .fixed(17)
        case .footnoteSpecial: return .fixed(17)
        case .footnoteCaption: return .fixed(17)
        case .metaText: return .fixed(16)
        case .infoCaption: return .fixed(15)
        }
    }

    var minSizeEnforcement: OWFontSizeEnforcement {
        switch self {
        case .titleLarge: return .none
        case .titleMedium: return .none
        case .titleSmall: return .none
        case .bodyText: return .none
        case .bodyInteraction: return .none
        case .bodyContext: return .none
        case .bodySpecial: return .none
        case .footnoteText: return .none
        case .footnoteLink: return .none
        case .footnoteContext: return .none
        case .footnoteSpecial: return .none
        case .footnoteCaption: return .none
        case .metaText: return .none
        case .infoCaption: return .none
        }
    }
}

enum OWFontSizeEnforcement {
    case fixed(CGFloat)
    case none
}
