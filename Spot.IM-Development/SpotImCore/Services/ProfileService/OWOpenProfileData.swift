//
//  OWOpenProfileData.swift
//  SpotImCore
//
//  Created by Refael Sommer on 04/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

public struct OWOpenProfileData {
    public let url: URL
    public let userProfileType: OWUserProfileType
    public let userId: String
}

extension OWOpenProfileData: Equatable, Codable {
    public static func == (lhs: OWOpenProfileData, rhs: OWOpenProfileData) -> Bool {
        return rhs.url == lhs.url &&
                rhs.userProfileType == lhs.userProfileType &&
                rhs.userId == lhs.userId
    }
}
