//
//  OWNetworkEnvironmentType.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 21/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

#if BETA
public enum OWNetworkEnvironmentType {
    case production
    case staging
    case cluster1d
}
#else
enum OWNetworkEnvironmentType {
    case production
    case staging
    case cluster1d
}
#endif

