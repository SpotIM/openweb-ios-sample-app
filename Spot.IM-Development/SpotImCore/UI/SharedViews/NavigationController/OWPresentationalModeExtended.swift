//
//  OWPresentationalModeExtended.swift
//  SpotImCore
//
//  Created by Alon Haiut on 11/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

enum OWPresentationalModeExtended {
    case present(viewControllerWeakEncapsulation: OWWeakEncapsulation<UIViewController>, style: OWModalPresentationStyle, animated: Bool)
    case push(navigationController: UINavigationController)
}
