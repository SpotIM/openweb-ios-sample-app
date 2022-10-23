//
//  OWInitializable.swift
//  SpotImCore
//
//  Created by Alon Haiut on 18/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

protocol OWInitializable {
    init()
}

extension CALayer: OWInitializable {}
