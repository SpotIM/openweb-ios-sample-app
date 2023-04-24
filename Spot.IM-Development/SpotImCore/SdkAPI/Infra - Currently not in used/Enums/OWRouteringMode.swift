//
//  OWRouteringMode.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWRouteringMode {
    case none
    case flow(navigationController: UINavigationController)
}
#else
enum OWRouteringMode {
    case none
    case flow(navigationController: UINavigationController)
}
#endif
