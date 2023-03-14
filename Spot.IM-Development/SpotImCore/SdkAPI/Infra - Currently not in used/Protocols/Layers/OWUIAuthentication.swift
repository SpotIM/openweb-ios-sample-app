//
//  OWUIAuthentication.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWUIAuthentication {
    var displayAuthenticationFlow: OWLoginFlowCallback? { get set }
}
#else
protocol OWUIAuthentication {
    var displayAuthenticationFlow: OWLoginFlowCallback? { get set }
}
#endif
