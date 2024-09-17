//
//  DevelopmentGenericSSOAuthentication.swift
//  OpenWeb-SampleApp-Internal-Configs
//
//  Created by Alon Haiut on 15/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public struct DevelopmentGenericSSOAuthentication {
    public let displayName: String
    public let spotId: String
    public let ssoToken: String
    public let user: DevelopmentUserAuthentication
}

public extension DevelopmentGenericSSOAuthentication {
    static func developmentModels() -> [DevelopmentGenericSSOAuthentication] {
        return [
            // All those Users are for The demo spot `sp_eCIlROSD`
            DevelopmentGenericSSOAuthentication(displayName: "Alon Haiut",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "alon_h",
                                                                                    password: "12345",
                                                                                    userId: "u_VjboM8IDXIhs")),
            DevelopmentGenericSSOAuthentication(displayName: "Alon Shprung",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "alon_s",
                                                                                    password: "12345",
                                                                                    userId: "u_DlHL06mEamDM")),
            DevelopmentGenericSSOAuthentication(displayName: "Nogah Melamed",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "nogah_m",
                                                                                    password: "12345",
                                                                                    userId: "u_fmQrWFmhahqk")),
            DevelopmentGenericSSOAuthentication(displayName: "Refael Sommer",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "refael_s",
                                                                                    password: "12345",
                                                                                    userId: "u_VKy60SyKlfeq")),
            DevelopmentGenericSSOAuthentication(displayName: "Revital Pisman",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "revital_p",
                                                                                    password: "12345",
                                                                                    userId: "u_03xiyoRp2Gbd")),
            DevelopmentGenericSSOAuthentication(displayName: "Test-User",
                                                spotId: "sp_eCIlROSD",
                                                ssoToken: "03190715DchJcY",
                                                user: DevelopmentUserAuthentication(username: "test",
                                                                                    password: "1234",
                                                                                    userId: "u_lAt51Sg8WoDL"))
        ]
    }

    static func automationModels() -> [DevelopmentGenericSSOAuthentication] {
        return [
            // All those Users are for spot `sp_f1f0OMkt`
            DevelopmentGenericSSOAuthentication(displayName: "AT-Test-User",
                                                spotId: "sp_f1f0OMkt",
                                                ssoToken: "03230530ruvFh2.65386531333139612d336534382d343038662d386165352d6366326130343965",
                                                user: DevelopmentUserAuthentication(username: "test",
                                                                                    password: "1234",
                                                                                    userId: "1")),
            DevelopmentGenericSSOAuthentication(displayName: "AT-Test-User2",
                                                spotId: "sp_f1f0OMkt",
                                                ssoToken: "03230530ruvFh2.65386531333139612d336534382d343038662d386165352d6366326130343965",
                                                user: DevelopmentUserAuthentication(username: "test2",
                                                                                    password: "asdf12345",
                                                                                    userId: "2")),
            DevelopmentGenericSSOAuthentication(displayName: "AT-Test-User3",
                                                spotId: "sp_f1f0OMkt",
                                                ssoToken: "03230530ruvFh2.65386531333139612d336534382d343038662d386165352d6366326130343965",
                                                user: DevelopmentUserAuthentication(username: "test3",
                                                                                    password: "123qwe",
                                                                                    userId: "3"))
        ]
    }
}
