//
//  OWConstraintConfig.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

// important: we can set this typealias to be the one we are working with in the SDK and then with leading and trailing position UI stuff according to the current language direction
typealias OWConstraintInterfaceLayoutDirection = UIUserInterfaceLayoutDirection

struct OWConstraintConfig {
    static var interfaceLayoutDirection: OWConstraintInterfaceLayoutDirection = .leftToRight
}
