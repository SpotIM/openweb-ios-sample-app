//
//  OWHelpers.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWHelpers {
    var additionalConfigurations: [OWAdditionalConfiguration] { get set }
}
#else
protocol OWHelpers {
    var additionalConfigurations: [OWAdditionalConfiguration] { get set }
}
#endif
