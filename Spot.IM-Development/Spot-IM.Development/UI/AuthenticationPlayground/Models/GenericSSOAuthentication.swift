//
//  GenericSSOAuthentication.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct GenericSSOAuthentication {
    let domainName: String
    let spotId: String
    let ssoToken: String
    let user: UserAuthentication
}

extension GenericSSOAuthentication {
    static let mockModels = Self.createMockModels()
    
    static func createMockModels() -> [GenericSSOAuthentication] {
    #if PUBLIC_DEMO_APP
        return []
    #else
        return [
            GenericSSOAuthentication(domainName: "Test-Mobile-SSO",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "",
                                     user: UserAuthentication(username: "test",
                                                              password: "1234",
                                                              userToken: "03190715DchJcY"))
        ]
    #endif
    }
}
