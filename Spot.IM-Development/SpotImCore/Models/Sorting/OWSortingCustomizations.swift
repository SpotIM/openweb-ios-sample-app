//
//  OWSortingCustomizations.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol OWSortingCustomizations {
    func setTitle(_ title: String, forOption sortOption: OWSortOption)
    var initialOption: OWSortOption { get set }
}

class OWSortingCustomizer: OWSortingCustomizations {
    func setTitle(_ title: String, forOption sortOption: OWSortOption) {
        // TODO: Complete
    }
    
    var initialOption: OWSortOption = .default
}
