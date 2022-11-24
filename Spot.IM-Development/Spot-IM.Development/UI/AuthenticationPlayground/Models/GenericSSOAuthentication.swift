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
                                     user: UserAuthentication(username: "alon_h",
                                                              password: "12345",
                                                              userId: "u_VjboM8IDXIhs")),
            GenericSSOAuthentication(displayName: "Alon Shprung",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "alon_s",
                                                              password: "12345",
                                                              userId: "u_DlHL06mEamDM")),
            GenericSSOAuthentication(displayName: "Nogah Melamed",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "nogah_m",
                                                              password: "12345",
                                                              userId: "u_fmQrWFmhahqk")),
            GenericSSOAuthentication(displayName: "Refael Sommer",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "refael_s",
                                                              password: "12345",
                                                              userId: "u_VKy60SyKlfeq")),
            GenericSSOAuthentication(displayName: "Revital Pisman",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "revital_p",
                                                              password: "12345",
                                                              userId: "u_03xiyoRp2Gbd")),
            GenericSSOAuthentication(displayName: "Test-User",
                                     spotId: "sp_eCIlROSD",
                                     ssoToken: "03190715DchJcY",
                                     user: UserAuthentication(username: "test",
                                                              password: "1234",
                                                              userId: "u_lAt51Sg8WoDL"))
        ]
#endif
    }
}
