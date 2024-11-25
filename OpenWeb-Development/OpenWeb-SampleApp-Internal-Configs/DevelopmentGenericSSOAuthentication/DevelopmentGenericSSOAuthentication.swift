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
            DevelopmentGenericSSOAuthentication(displayName: "Test-User",
                                                spotId: demoSpotID,
                                                ssoToken: demoSSOToken,
                                                user: DevelopmentUserAuthentication(username: "test",
                                                                                    password: "1234",
                                                                                    userId: "u_lAt51Sg8WoDL")),
            demoUser(displayName: "Alon Haiut", username: "alon_h", userId: "u_VjboM8IDXIhs"),
            demoUser(displayName: "Alon Shprung", username: "alon_s", userId: "u_DlHL06mEamDM"),
            demoUser(displayName: "Anael Peguine", username: "anael_p", userId: "u_K2uWaOcfRZBX"),
            demoUser(displayName: "Guy Shoham", username: "guy_s", userId: "u_pPAWB9sIYt99"),
            demoUser(displayName: "Liran Nahum", username: "liran_n", userId: "u_JVLw4Cl2FqJP"),
            demoUser(displayName: "Mykhailo Nester", username: "mykhailo_n", userId: "u_DOU0vK7vxB0r"),
            demoUser(displayName: "Nogah Melamed", username: "nogah_m", userId: "u_fmQrWFmhahqk"),
            demoUser(displayName: "Refael Sommer", username: "refael_s", userId: "u_VKy60SyKlfeq"),
            demoUser(displayName: "Revital Pisman", username: "revital_p", userId: "u_03xiyoRp2Gbd"),
            demoUser(displayName: "Yonat Sharon", username: "yonat_s", userId: "u_22B3rFbqTLCs")
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

    private static let demoSpotID = "sp_eCIlROSD"
    private static let demoSSOToken = "03190715DchJcY"
    private static let demoPassword = "12345"

    private static func demoUser(displayName: String, username: String, userId: String) -> DevelopmentGenericSSOAuthentication {
        DevelopmentGenericSSOAuthentication(displayName: displayName,
                                            spotId: demoSpotID,
                                            ssoToken: demoSSOToken,
                                            user: DevelopmentUserAuthentication(username: username,
                                                                                password: demoPassword,
                                                                                userId: userId))
    }
}
