//
//  ArticleModel.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 14/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

public struct Post: Decodable {

    enum CodingKeys: String, CodingKey {
        case spotId, conversationId, publishedAt, extractData
    }

    let spotId: String
    let conversationId: String
    let publishedAt: String
    let extractData: Article
}

public struct Article: Decodable {

    enum CodingKeys: String, CodingKey {
        case url, title, width, height, description, thumbnailUrl
    }

    let url: String
    let title: String
    let width: Int
    let height: Int
    let description: String
    let thumbnailUrl: String
}
