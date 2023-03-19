//
//  OWSSOFlowType.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSSOFlowType {
    case start(completion: OWSSOStartHandler)
    case complete(codeB: String, completion: OWSSOCompletionHandler)
    case usingProvider(privder: OWSSOProvider, token: String, completion: OWProviderSSOHandler)
}
#else
enum OWSSOFlowType {
    case start(completion: OWSSOStartHandler)
    case complete(codeB: String, completion: OWSSOCompletionHandler)
    case usingProvider(privder: OWSSOProvider, token: String, completion: OWProviderSSOHandler)
}
#endif
