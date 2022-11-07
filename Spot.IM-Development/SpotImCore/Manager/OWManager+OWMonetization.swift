//
//  OWManager+OWMonetization.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

extension OWManager: OWMonetization {
    var monetization: OWMonetization { return monetizationLayer }
}
