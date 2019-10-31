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
}
