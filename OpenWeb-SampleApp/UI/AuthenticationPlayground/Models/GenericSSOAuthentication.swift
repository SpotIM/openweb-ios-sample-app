//
//  GenericSSOAuthentication.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

struct GenericSSOAuthentication {
    var displayName: String
    var spotId: String
    var ssoToken: String
    var user: UserAuthentication
}

extension GenericSSOAuthentication {
    static var mockModels = Self.createMockModels()

    static func createMockModels() -> [GenericSSOAuthentication] {
        var authenticationModels: [GenericSSOAuthentication] = []

        // TODO: add some public "users" that can demonstrate creating comment and such for the public Sample Api preset
        let publicModels: [GenericSSOAuthentication] = []
        authenticationModels.append(contentsOf: publicModels)

    #if !PUBLIC_DEMO_APP
        let developmentModels = DevelopmentGenericSSOAuthentication.developmentModels().map { $0.toGenericSSOAuthentication() }
        authenticationModels.append(contentsOf: developmentModels)

        #if ADS
            let adsDevelopmentModels = DevelopmentGenericSSOAuthentication.developmentAdsModels().map { $0.toGenericSSOAuthentication() }
            authenticationModels.append(contentsOf: adsDevelopmentModels)
        #endif
    #endif

    #if AUTOMATION
        let automationModels = DevelopmentGenericSSOAuthentication.automationModels().map { $0.toGenericSSOAuthentication() }
        authenticationModels.append(contentsOf: automationModels)
    #endif

        return authenticationModels
    }
}
