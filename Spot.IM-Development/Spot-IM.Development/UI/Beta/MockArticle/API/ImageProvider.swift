//
//  AnimalImageProvider.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

protocol ImageProviding {
    func randomImageUrl() -> URL
}

class ImageProvider: ImageProviding {
    fileprivate struct Metrics {
        static let imageSize: Int = 600
        static let baseURL: String = "https://picsum.photos/id"
        static let maxId: Int = 100
    }
    
    func randomImageUrl() -> URL {
        let id = Int.random(in: 1...Metrics.maxId)
        let urlPath = "\(Metrics.baseURL)/\(id)/\(Metrics.imageSize)/\(Metrics.imageSize)"
        return URL(string: urlPath)!
    }
}
