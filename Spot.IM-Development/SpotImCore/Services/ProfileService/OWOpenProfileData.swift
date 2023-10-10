//
//  OWOpenProfileData.swift
//  SpotImCore
//
//  Created by Refael Sommer on 04/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if NEW_API
public struct OWOpenProfileData {
    public let url: URL
    public let userProfileType: OWUserProfileType
    public let userId: String
}
#else
struct OWOpenProfileData {
    let url: URL
    let userProfileType: OWUserProfileType
    let userId: String
}
#endif

#if NEW_API
extension OWOpenProfileData: Equatable, Codable {
    public static func == (lhs: OWOpenProfileData, rhs: OWOpenProfileData) -> Bool {
        return rhs.url == lhs.url &&
                rhs.userProfileType == lhs.userProfileType &&
                rhs.userId == lhs.userId
    }
}
#else
extension OWOpenProfileData: Equatable, Codable {
    static func == (lhs: OWOpenProfileData, rhs: OWOpenProfileData) -> Bool {
        return rhs.url == lhs.url &&
                rhs.userProfileType == lhs.userProfileType &&
                rhs.userId == lhs.userId
    }
}
#endif
