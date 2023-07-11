//
//  SPConversationExtraDataRM.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal struct SPConversationExtraDataRM: Decodable {
    var url: URL?
    var type: String?
    var title: String?
    var width: Int?
    var height: Int?
    var service: String?
    var imageId: String?
//    var metadata: String? // type?
    var description: String?
    var thumbnailUrl: URL?

    enum CodingKeys: String, CodingKey {
        case url, type, title, width, height, service, imageId, description, thumbnailUrl
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try? values.decode(URL.self, forKey: .url)
        self.type = try? values.decode(String.self, forKey: .type)
        self.title = try? values.decode(String.self, forKey: .title)
        self.width = try? values.decode(Int.self, forKey: .width)
        self.height = try? values.decode(Int.self, forKey: .height)
        self.service = try? values.decode(String.self, forKey: .service)
        self.imageId = try? values.decode(String.self, forKey: .imageId)
        self.description = try? values.decode(String.self, forKey: .description)
        self.thumbnailUrl = try? values.decode(URL.self, forKey: .thumbnailUrl)
    }
}
