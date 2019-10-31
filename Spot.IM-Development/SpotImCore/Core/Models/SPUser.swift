//
//  SPUser.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

enum ABGroup: CaseIterable {
    /// Banner on preconversation screen
    case first
    /// Banner on preconversation screen + interstitial on "show more comments" transition
    case second
    /// Banner on preconversation screen + sticky banner on main conversation screen
    case third
}

internal class SPUser: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id, userId, displayName, userName, imageId, registered,
        isAdmin, isModerator, isSuperAdmin, isJournalist, badgeType, points
    }
    
    // all users
    private var userId: String?
    var id: String?
    var displayName: String?
    var userName: String?
    var imageId: String?
    var registered: Bool
    var isAdmin: Bool
    var isModerator: Bool
    var isSuperAdmin: Bool
    var isJournalist: Bool
    var badgeType: String?

    // commenter only
    var points: Int?
    var online: Bool? = false

    /// Admin, Moderator or Journalist
    var isAuthority: Bool {
        return isAdmin || isModerator || isJournalist
    }

    var abTestGroup: ABGroup?
    
    var hasGamification: Bool {
        if let badgeType = badgeType, badgeType != "newbie" {
            return true
        } else {
            return false
        }
    }

    var authorityTitle: String? {
        if isAdmin {
            return NSLocalizedString("Admin", bundle: Bundle.spot, comment: "Authority title")
        } else if isSuperAdmin {
            return NSLocalizedString("Moderator", bundle: Bundle.spot, comment: "Authority title")
        } else if isJournalist {
            return NSLocalizedString("Journalist", bundle: Bundle.spot, comment: "Authority title")
        } else {
            return nil
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        abTestGroup = (SPConfigDataSource.config?.initialization?.monetized ?? false)
            ? ABGroup.allCases.randomElement()
            : nil
        id = try? container.decode(String.self, forKey: .id)
        badgeType = try? container.decode(String.self, forKey: .badgeType)
        displayName = try? container.decode(String.self, forKey: .displayName)
        imageId = try? container.decode(String.self, forKey: .imageId)
        isAdmin = (try? container.decode(Bool.self, forKey: .isAdmin)) ?? false
        isJournalist = (try? container.decode(Bool.self, forKey: .isJournalist)) ?? false
        isModerator = (try? container.decode(Bool.self, forKey: .isModerator)) ?? false
        isSuperAdmin = (try? container.decode(Bool.self, forKey: .isSuperAdmin)) ?? false
        points = try? container.decode(Int.self, forKey: .points)
        registered = (try? container.decode(Bool.self, forKey: .registered)) ?? false
        userId = try? container.decode(String.self, forKey: .userId)
        userName = try? container.decode(String.self, forKey: .userName)
        id = id ?? userId
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
    }
    
    func imageURL(size: CGSize) -> URL? {
        guard var id = imageId else { return nil }
        
        if id.hasPrefix(Constants.placeholderImagePrefix) {
            id.removeFirst(Constants.placeholderImagePrefix.count)
            id = Constants.avatarPathComponent.appending(id)
        }
        
        return URL(string: cloudinaryURLString(size).appending(id))
    }
    
    private func cloudinaryURLString(_ imageSize: CGSize) -> String {
        var result = Constants.cloudinaryBaseURL.appending(Constants.cloudinaryParamString)
        result.append("\(Constants.cloudinaryWidthPrefix)" +
            "\(Int(imageSize.width))" +
            "\(Constants.cloudinaryHeightPrefix)" +
            "\(Int(imageSize.height))"
        )
        
        return result.appending("/")
    }
}

private enum Constants {
    static let cloudinaryBaseURL = "https://images.spot.im/image/upload/"
    static let cloudinaryParamString = "dpr_3,c_thumb,g_face"
    static let cloudinaryWidthPrefix = ",w_"
    static let cloudinaryHeightPrefix = ",h_"
    static let placeholderImagePrefix = "#"
    static let avatarPathComponent = "avatars/"
}
