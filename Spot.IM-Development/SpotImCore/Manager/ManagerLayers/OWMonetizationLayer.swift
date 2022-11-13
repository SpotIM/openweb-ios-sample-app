//
//  OWMonetizationLayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

class OWMonetizationLayer: OWMonetization {
    var adsProvider: OWAdsProvider {
        get {
            return self._adsProvider
        }
        set(newValue) {
            _adsProvider = newValue
        }
    }
    
    fileprivate var _adsProvider: OWAdsProvider = .none
}
