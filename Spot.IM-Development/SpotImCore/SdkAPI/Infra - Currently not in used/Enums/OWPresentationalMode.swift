//
//  OWPresentationalMode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWPresentationalMode {
    case present(viewController: UIViewController, style: OWModalPresentationStyle = .pageSheet)
    case push(navigationController: UINavigationController)

    var style: OWPresentationalModeCompact {
        switch self {
        case .present(_, let style):
            return .present(style: style)
        case .push(_):
            return .push
        }
    }
}
#else
enum OWPresentationalMode {
    case present(viewController: UIViewController, style: OWModalPresentationStyle = .pageSheet)
    case push(navigationController: UINavigationController)
}
#endif
