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
        status, hasNext, edited, deleted, published, rank, content, users, replies, isReply, additionalData, strictMode
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
    var users: [String: SPUser]?
    var replies: [SPComment]?
    var additionalData: AdditionalData?
    var strictMode: Bool?

    var isReply: Bool {
        guard let id = id, let rootComment = rootComment else {
            return false
        }
        return id != rootComment
    }

    mutating func setIsEdited(_ editedStatus: Bool) {
        edited = editedStatus
    }

    var status: CommentStatus? {
        guard let rawStatus = rawStatus else { return nil }
        let status = CommentStatus(rawValue: rawStatus)
        return status == .unknown ? nil : status
    }

    var text: Content.Text?
    var gif: Content.Animation?
    var image: Content.Image?

    // empty init
    init() {
        id = nil
        parentId = nil
        rootComment = nil
        depth = nil
        userId = nil
        writtenAt = nil
        time = nil
        self.repliesCount = nil
        offset = nil
        rawStatus = nil
        hasNext = false
        edited = false
        deleted = false
        published = false
        rank = nil
        content = nil
        users = nil
        replies = nil
        additionalData = nil
        strictMode = nil
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
        published = (try? container.decode(Bool.self, forKey: .published)) ?? false
        rank = try? container.decode(Rank.self, forKey: .rank)
        content = try? container.decode([Content].self, forKey: .content)
        if let content = content {
            for contentItem in content {
                switch contentItem {
                case .text(let textContent):
                    self.text = textContent
                    break
                case .image(let imageContent):
                    self.image = imageContent
                    break
                case .animation(let animationContent):
                    self.gif = animationContent
                    break
                case .none:
                    break
                }
            }
        }
        users = try? container.decode([String: SPUser].self, forKey: .users)
        replies = try? container.decode([SPComment].self, forKey: .replies)
        additionalData = try? container.decode(AdditionalData.self, forKey: .additionalData)
        strictMode = try? container.decode(Bool.self, forKey: .strictMode)
    }

    enum CommentStatus: String {
        case unknown
        case block
        case reject
        case pending
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
            case "reject":
                self = .reject
            case "pending":
                self = .pending
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

    enum Content: Decodable, Equatable {

        enum CodingKeys: CodingKey {
            case type, id, text, previewWidth, previewHeight, originalWidth, originalHeight, originalUrl, imageId
        }

        struct Text: Decodable, Equatable {
            var id: String
            var text: String
        }

        struct Animation: Decodable, Equatable {
            var previewWidth: Int
            var previewHeight: Int
            var originalWidth: Int
            var originalHeight: Int
            var originalUrl: String
        }

        struct Image: Decodable, Equatable {
            var originalWidth: Int
            var originalHeight: Int
            var imageId: String
        }

        case text(Text)
        case animation(Animation)
        case image(Image)
        case none

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try? container.decode(String.self, forKey: .type)
            switch type {
            case "text":
                let id = try container.decode(String.self, forKey: .id)
                let text = try container.decode(String.self, forKey: .text)
                self = .text(Text(id: id, text: text))
            case "animation":
                let previewWidth = try container.decode(Int.self, forKey: .previewWidth)
                let previewHeight = try container.decode(Int.self, forKey: .previewHeight)
                let originalWidth = try container.decode(Int.self, forKey: .originalWidth)
                let originalHeight = try container.decode(Int.self, forKey: .originalHeight)
                let originalUrl = try container.decode(String.self, forKey: .originalUrl)
                self = .animation(Animation( previewWidth: previewWidth, previewHeight: previewHeight, originalWidth: originalWidth, originalHeight: originalHeight, originalUrl: originalUrl))
            case "image":
                let originalWidth = try container.decode(Int.self, forKey: .originalWidth)
                let originalHeight = try container.decode(Int.self, forKey: .originalHeight)
                let imageId = try container.decode(String.self, forKey: .imageId)
                self = .image(Image(originalWidth: originalWidth, originalHeight: originalHeight, imageId: imageId))
            default:
                self = .none
            }
        }
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
