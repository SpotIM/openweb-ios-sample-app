//
//  OWPresentationalMode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

// Will be a public protocol
enum OWPresentationalMode {
    case present(viewController: UIViewController)
    case push(navigationController: UINavigationController)
}
