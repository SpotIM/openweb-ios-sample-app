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
    case present(viewController: UIViewController)
    case push(navigationController: UINavigationController)
}
#else
enum OWPresentationalMode {
    case present(viewController: UIViewController)
    case push(navigationController: UINavigationController)
}
#endif
