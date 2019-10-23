//
//  Bundle+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Itay Dressler on 16/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension Bundle {
    static let spot = Bundle(identifier: "im.spot.Spot-IM-Core.SpotImCore")
    
    func shortVersion() -> String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
