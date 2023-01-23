//
//  OWImageProvider.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 10/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

internal protocol OWImageProviding {
    func imageURL(with id: String, size: CGSize?) -> Observable<URL?>
}

class OWCloudinaryImageProvider: OWImageProviding {
    
    fileprivate struct Metrics {
        static let placeholderImagePrefix = "#"
        static let avatarPathComponent = "avatars/"
        static let cloudinaryImageParamString = "dpr_3,c_thumb,g_face"
        static let cloudinaryWidthPrefix = ",w_"
        static let cloudinaryHeightPrefix = ",h_"
        static let defaultBaseUrl = "https://images.spot.im/image/upload/"
    }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
    
    func imageURL(with id: String, size: CGSize? = nil) -> Observable<URL?> {
        var urlSuffix = id
        
        if urlSuffix.hasPrefix(Metrics.placeholderImagePrefix) {
            urlSuffix.removeFirst(Metrics.placeholderImagePrefix.count)
            urlSuffix = Metrics.avatarPathComponent.appending(urlSuffix)
        }
        return _fetchImageBaseUrl
            .take(1)
            .map { [weak self] baseUrl in
                guard let self = self else { return nil }
                let cloudinaryUrlString = self.cloudinaryURLString(size, baseUrl: baseUrl)
                return URL(string: cloudinaryUrlString.appending(urlSuffix))
            }
            .asObservable()
    }
    
    fileprivate var _fetchImageBaseUrl: Observable<String> {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> String in
                return config.mobileSdk.fetchImageBaseUrl
            }
            .asObservable()
    }
}

fileprivate extension OWCloudinaryImageProvider {
    func cloudinaryURLString(_ imageSize: CGSize? = nil, baseUrl: String) -> String {
        var result = baseUrl.appending(Metrics.cloudinaryImageParamString)
        
        if let imageSize = imageSize {
            result.append("\(Metrics.cloudinaryWidthPrefix)" +
                "\(Int(imageSize.width))" +
                "\(Metrics.cloudinaryHeightPrefix)" +
                "\(Int(imageSize.height))"
            )
        }
        
        return result.appending("/")
    }
}
