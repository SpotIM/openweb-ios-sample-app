//
//  UIImage+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal extension UIImage {
    convenience init?(spNamed: String) {
        self.init(named: spNamed, in: Bundle.spot, compatibleWith: nil)
    }
}
