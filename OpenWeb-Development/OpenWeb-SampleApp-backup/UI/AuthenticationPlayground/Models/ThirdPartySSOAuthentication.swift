//
//  ThirdPartySSOAuthentication.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 29/11/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK
#if !PUBLIC_DEMO_APP
    import OpenWeb_SampleApp_Internal_Configs
#endif

struct ThirdPartySSOAuthentication {
    let displayName: String
    let spotId: String
    let token: String
    let provider: OWSSOProvider
}

extension ThirdPartySSOAuthentication {
    static let mockModels = Self.createMockModels()

    static func createMockModels() -> [ThirdPartySSOAuthentication] {
    #if PUBLIC_DEMO_APP
        return []
    #else
        return DevelopmentThirdPartySSOAuthentication.developmentModels().map { $0.toThirdPartySSOAuthentication() }
    #endif
    }
}
