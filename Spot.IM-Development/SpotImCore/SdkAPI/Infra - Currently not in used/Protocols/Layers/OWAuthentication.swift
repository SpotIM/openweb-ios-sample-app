//
//  OWAuthentication.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWAuthentication {
    func sso(_ flowType: OWSSOFlowType)
    func userStatus(completion: @escaping OWUserAuthenticationStatusCompletion)
    func logout(completion: @escaping OWDefaultCompletion)
    var renewSSO: OWRenewSSOCallback? { get set }
    var shouldDisplayLoginPrompt: Bool { get set }
}
#else
protocol OWAuthentication {
    func sso(_ flowType: OWSSOFlowType)
    func userStatus(completion: @escaping OWUserAuthenticationStatusCompletion)
    func logout(completion: @escaping OWDefaultCompletion)
    var renewSSO: OWRenewSSOCallback? { get set }
    var shouldDisplayLoginPrompt: Bool { get set }
}
#endif
