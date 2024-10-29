//
//  OWMonetizationLayer.swift
//  OpenWebSDKAdapter
//
//  Created by Alon Shprung on 14/10/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
#if canImport(OpenWebIAUSDK)
@_exported import OpenWebIAUSDK
#endif

#if canImport(OpenWebIAUSDK)
public class OWMonetizationLayer: OWMonetization {
    // TODO - lmplementation
    public init() {}
}
#else
public class OWMonetizationLayer: OWMonetization {
    public init() {}
}
#endif

