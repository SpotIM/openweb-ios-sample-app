//
//  OWCompactRouter.swift
//  SpotImCore
//
//  Created by Alon Haiut on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

protocol OWCompactRoutering {
    var topController: UIViewController? { get }
}

class OWCompactRouter: NSObject, OWCompactRoutering {

    weak var topController: UIViewController?

    init(topController: UIViewController?) {
        self.topController = topController
    }
}
