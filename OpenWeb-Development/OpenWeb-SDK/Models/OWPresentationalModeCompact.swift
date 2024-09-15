//
//  OWPresentationalModeCompact.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 10/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWPresentationalModeCompact: Codable {
    case present(style: OWModalPresentationStyle)
    case push
    case none

    var presentationalMode: OWPresentationalMode {
        switch self {
        case .present(style: let style):
            return OWPresentationalMode.present(viewController: UIViewController(), style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: UINavigationController())
        case .none:
            return OWPresentationalMode.push(navigationController: UINavigationController())
        }
    }
}
