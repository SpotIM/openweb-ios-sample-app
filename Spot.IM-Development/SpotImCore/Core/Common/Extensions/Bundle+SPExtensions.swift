//
//  Bundle+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Itay Dressler on 16/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

extension Bundle {
    static let spot = Bundle(for: BundleToken.self)
    
    var shortVersion: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var bundleIdentifier: String? {
        return self.infoDictionary?[kCFBundleIdentifierKey as String] as? String
    }
}


private final class BundleToken {}
