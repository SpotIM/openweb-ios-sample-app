//
//  SPUser.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal class SPUser: Codable, CustomDebugStringConvertible, Equatable {
    static func == (lhs: SPUser, rhs: SPUser) -> Bool {
        return lhs.userId == rhs.userId
    }

    enum CodingKeys: String, CodingKey {
        case id, userId, displayName, userName, imageId, registered,
        isAdmin, isModerator, isCommunityModerator, isSuperAdmin, isJournalist, isMuted, badgeType, points, tokenExpiration, ssoData, ssoPrimaryKey
    }

    // all users
    var userId: String?
    var id: String?
    var displayName: String?
    var userName: String?
    var imageId: String?
    var registered: Bool
    var isAdmin: Bool
    var isModerator: Bool
    var isCommunityModerator: Bool
    var isSuperAdmin: Bool
    var isJournalist: Bool
    let isMuted: Bool
    let badgeType: String
    let tokenExpiration: Int?
    let ssoData: SPSSOData?
    var ssoPublisherId: String?

    // commenter only
    var points: Int?
    var online: Bool? = false

    /// Admin, Moderator or Journalist
    var isAuthority: Bool {
        return isAdmin || isModerator || isJournalist
    }

    var isStaff: Bool {
        return isSuperAdmin || isAdmin || isJournalist || isModerator || isCommunityModerator
    }

    var hasGamification: Bool {
        if !badgeType.isEmpty && badgeType != "newbie" {
            return true
        } else {
            return false
        }
    }

    var authorityTitle: String? {
        if isAdmin || isSuperAdmin || isModerator || isJournalist {
            return SPLocalizationManager.localizedString(key: "Staff")
        } else if isCommunityModerator {
            return SPLocalizationManager.localizedString(key: "Community Moderator")
        } else {
            return nil
        }
    }

    var expired: Bool {
        guard let tokenExpiration = tokenExpiration else {
            return true
        }

        let now = Date().timeIntervalSince1970
        return tokenExpiration <= Int(now)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decode(String.self, forKey: .id)
        do {
            badgeType = try container.decode(String.self, forKey: .badgeType)
        } catch {
            badgeType = ""
        }
        displayName = try? container.decode(String.self, forKey: .displayName)
        imageId = try? container.decode(String.self, forKey: .imageId)
        isAdmin = (try? container.decode(Bool.self, forKey: .isAdmin)) ?? false
        isJournalist = (try? container.decode(Bool.self, forKey: .isJournalist)) ?? false
        isModerator = (try? container.decode(Bool.self, forKey: .isModerator)) ?? false
        isCommunityModerator = (try? container.decode(Bool.self, forKey: .isCommunityModerator)) ?? false
        isSuperAdmin = (try? container.decode(Bool.self, forKey: .isSuperAdmin)) ?? false
        points = try? container.decode(Int.self, forKey: .points)
        registered = (try? container.decode(Bool.self, forKey: .registered)) ?? false
        userId = try? container.decode(String.self, forKey: .userId)
        userName = try? container.decode(String.self, forKey: .userName)
        tokenExpiration = try? container.decode(Int.self, forKey: .tokenExpiration)
        ssoData = try? container.decode(SPSSOData?.self, forKey: .ssoData)
        id = id ?? userId
        ssoPublisherId = try? container.decode(String.self, forKey: .ssoPrimaryKey)
        isMuted = (try? container.decode(Bool.self, forKey: .isMuted)) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(badgeType, forKey: .badgeType)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(imageId, forKey: .imageId)
        try container.encode(isAdmin, forKey: .isAdmin)
        try container.encode(isJournalist, forKey: .isJournalist)
        try container.encode(isModerator, forKey: .isModerator)
        try container.encode(isSuperAdmin, forKey: .isSuperAdmin)
        try container.encode(points, forKey: .points)
        try container.encode(registered, forKey: .registered)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encode(tokenExpiration, forKey: .tokenExpiration)
        try container.encode(ssoData, forKey: .ssoData)
        try container.encode(ssoPublisherId, forKey: .ssoPrimaryKey)
        try container.encode(isMuted, forKey: .isMuted)
    }

    func imageURL(size: CGSize) -> URL? {
        guard var id = imageId else { return nil }

        if id.hasPrefix(SPImageRequestConstants.placeholderImagePrefix) {
            id.removeFirst(SPImageRequestConstants.placeholderImagePrefix.count)
            id = SPImageRequestConstants.avatarPathComponent.appending(id)
        }

        return URL(string: cloudinaryURLString(size).appending(id))
    }

    private func cloudinaryURLString(_ imageSize: CGSize) -> String {
        var result = APIConstants.fetchImageBaseURL.appending(SPImageRequestConstants.cloudinaryImageParamString)
        result.append("\(SPImageRequestConstants.cloudinaryWidthPrefix)" +
            "\(Int(imageSize.width))" +
            "\(SPImageRequestConstants.cloudinaryHeightPrefix)" +
            "\(Int(imageSize.height))"
        )

        return result.appending("/")
    }

    var debugDescription: String {
        var result = "\n"
        result += "DEBUG: This is user: \(String(describing: id))\n"
        result += "DEBUG: Display Name: \(String(describing: displayName))\n"
        result += "DEBUG: User Name: \(String(describing: userName))\n"
        result += "DEBUG: Is Registered: \(registered)\n"
        result += "DEBUG: Token Expiration: \(String(describing: Date(timeIntervalSince1970: TimeInterval(tokenExpiration ?? 0))))"
        return result
    }
}
