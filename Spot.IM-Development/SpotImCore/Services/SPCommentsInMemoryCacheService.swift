//
//  SPCommentsInMemoryCacheService.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/7/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

let commentCacheMinCount: Int = 10

final class SPCommentsInMemoryCacheService: OWCacheService<String, String> {
        
    func update(comment: String, with id: String) {
        self[id] = comment.count >= commentCacheMinCount ? comment : ""
    }
    
    func remove(for id: String) {
        self.remove(forKey: id)
    }
    
    func comment(for id: String) -> String {
        return self[id] ?? ""
    }
}
