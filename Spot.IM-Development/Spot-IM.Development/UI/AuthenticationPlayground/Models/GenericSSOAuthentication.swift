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
    let requiredUserLogin: Bool
    let user: UserAuthentication
}

extension GenericSSOAuthentication {
    static let mockModels = [
        GenericSSOAuthentication(domainName: "Test-Mobile-SSO",
                                 spotId: "sp_eCIlROSD",
                                 ssoToken: "",
                                 requiredUserLogin: true,
                                 user: UserAuthentication(username: "test",
                                                                                      password: "1234",
                                                                                      userToken: "03190715DchJcY")),
        GenericSSOAuthentication(domainName: "Yahoo",
                                 spotId: "sp_Rba9aFpG",
                                 ssoToken: "03200929UI9yij.458e37600305d9b8e34a9776baf4e9cddbc3fc2355c9da1ef5cc359309d89403",
                                 requiredUserLogin: false,
                                 user: UserAuthentication(username: "OpenWeb MobileTest",
                                                                                      password: "qR43ft426F",
                                                                                      userToken: "03190715DchJcY"))
    ]
}
