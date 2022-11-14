//
//  OWMonetization.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWMonetization {
    // TODO: Complete
}
#else
protocol OWMonetization {
    var adsProvider: OWAdsProvider { get set }
}
#endif
