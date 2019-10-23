//
//  SPCommentsInMemoryCacheService.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

let commentCacheMinCount: Int = 10

final class SPCommentsInMemoryCacheService {
    
    private var cachedComments: [String: String] = [:]
    
    func update(comment: String, with id: String) {
        cachedComments[id] = comment.count >= commentCacheMinCount ? comment : ""
    }
    
    func remove(for id: String) {
        cachedComments[id] = nil
    }
    
    func comment(for id: String) -> String {
        return cachedComments[id] ?? ""
    }
}
