//
//  GenericSSOAuthentication.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

struct GenericSSOAuthentication {
    let displayName: String
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
            // All those Users are for The demo spot `sp_eCIlROSD`
            GenericSSOAuthentication(displayName: "Alon Haiut",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "Alon H",
                                                              password: "12345",
                                                              userId: "27")),
            GenericSSOAuthentication(displayName: "Alon Shprung",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "Alon S",
                                                              password: "12345",
                                                              userId: "28")),
            GenericSSOAuthentication(displayName: "Nogah Melamed",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "Nogah M",
                                                              password: "12345",
                                                              userId: "29")),
            GenericSSOAuthentication(displayName: "Refael Sommer",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "Refael S",
                                                              password: "12345",
                                                              userId: "30")),
            GenericSSOAuthentication(displayName: "Revital Pisman",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "Revital P",
                                                              password: "12345",
                                                              userId: "31")),
            GenericSSOAuthentication(displayName: "Test-User",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "test",
                                                              password: "1234",
                                                              userId: "1"))
        ]
#endif
    }
}
