//
//  SPComment.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 21/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal struct SPComment: Decodable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case id, parentId, rootComment, depth, userId, writtenAt, time, repliesCount, totalRepliesCount, offset,
        status, hasNext, edited, deleted, published, rank, content, users, replies, isReply, additionalData
    }
    
    var id: String?
    var parentId: String?
    var rootComment: String?
    var depth: Int?
    var userId: String?
    var writtenAt: Double?
    var time: Double?
    var repliesCount: Int?
    var offset: Int?
    var rawStatus: String?
    var hasNext: Bool
    var edited: Bool
    var deleted: Bool
    var published: Bool

    var rank: Rank?
    var content: [Content]?
    var users: [String: CommentUser]?
    var replies: [SPComment]?
    var additionalData: AdditionalData?

    var isReply: Bool {
        guard let id = id, let rootComment = rootComment else {
            return false
        }
        return id != rootComment
    }

    var status: Status? {
        guard let rawStatus = rawStatus else { return nil }
        let status = Status(rawValue: rawStatus)
        return status == .unknown ? nil : status
    }
    
    var gif: Content? {
        guard let content = content else { return nil }
        for contentItem in content {
            if contentItem.type == "animation" {
                return contentItem
            }
        }
        return nil
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decode(String.self, forKey: .id)
        parentId = try? container.decode(String.self, forKey: .parentId)
        rootComment = try? container.decode(String.self, forKey: .rootComment)
        depth = try? container.decode(Int.self, forKey: .depth)
        userId = try? container.decode(String.self, forKey: .userId)
        writtenAt = try? container.decode(Double.self, forKey: .writtenAt)
        time = try? container.decode(Double.self, forKey: .time)
        let repliesCount = try? container.decode(Int.self, forKey: .repliesCount)
        let totalRepliesCount = try? container.decode(Int.self, forKey: .totalRepliesCount)
        self.repliesCount = totalRepliesCount ?? repliesCount
        offset = try? container.decode(Int.self, forKey: .offset)
        rawStatus = try? container.decode(String.self, forKey: .status)
        hasNext = (try? container.decode(Bool.self, forKey: .hasNext)) ?? false
        edited = (try? container.decode(Bool.self, forKey: .edited)) ?? false
        deleted = (try? container.decode(Bool.self, forKey: .deleted)) ?? false
        published = (try? container.decode(Bool.self, forKey: .published)) ?? true
        rank = try? container.decode(Rank.self, forKey: .rank)
        content = try? container.decode([Content].self, forKey: .content)
        users = try? container.decode([String: CommentUser].self, forKey: .users)
        replies = try? container.decode([SPComment].self, forKey: .replies)
        additionalData = try? container.decode(AdditionalData.self, forKey: .additionalData)
    }

    enum Status: String {
        case unknown
        case block
        case publishAndModerate
        case requireApproval

        init?(rawValue: String) {
            if rawValue.contains("block") {
                self = .block
                return
            }
            switch rawValue {
            case "publish_and_moderate":
                self = .publishAndModerate
            case "require_approval":
                self = .requireApproval
            default:
                self = .unknown
            }
        }
    }
}

extension SPComment {
    
    struct Rank: Decodable, Equatable {
        var ranksUp: Int?
        var ranksDown: Int?
        var rankedByCurrentUser: Int?
    }

    struct Content: Decodable, Equatable {
        // text content
        var id: String?
        var text: String?
        var type: String?
        // gif content
        var previewWidth: Int?
        var previewHeight: Int?
        var originalWidth: Int?
        var originalHeight: Int?
        var originalUrl: String?
    }

    struct CommentUser: Decodable, Equatable {
        var id: String?
    }
    
    struct AdditionalData: Decodable, Equatable {
        var labels: CommentLabel?
    }
    
    struct CommentLabel: Decodable, Equatable {
        var section: String?
        var ids: [String]?
    }
    
}
