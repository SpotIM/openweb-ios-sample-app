//
//  SubscriberBadgeService.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 01/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift


protocol SubscriberBadgeServicing {
    func badgeImage(config: OWSubscriberBadgeConfiguration) -> Observable<UIImage>
}

class SubscriberBadgeService: SubscriberBadgeServicing {
    
    fileprivate struct URLS {
        static let defaultSubscriberBadgeBaseUrl: String = "\(APIConstants.fetchImageBaseURL)\(SPImageRequestConstants.cloudinaryIconParamString)\(SPImageRequestConstants.iconPathComponent)"

        static let customSubscriberBadgeBaseUrl: String = "\(APIConstants.cdnBaseURL)\(SPImageRequestConstants.iconsPathComponent)\(SPImageRequestConstants.customPathComponent)"
    }
    
    fileprivate enum SubscriberBadgeIconType: String {
        case fontAwesome, custom
        func buildUrl(config: OWSubscriberBadgeConfiguration) -> URL {
            switch(self) {
            case .fontAwesome:
                return URL(string:"\(URLS.defaultSubscriberBadgeBaseUrl)\(config.type)-\(config.name).png")!
            case .custom:
                return URL(string:"\(URLS.customSubscriberBadgeBaseUrl)\(config.name).png")!
            }
        }
    }
    
    func badgeImage(config: OWSubscriberBadgeConfiguration) -> Observable<UIImage> {
        
        let iconType = SubscriberBadgeIconType(rawValue: config.type) ?? SubscriberBadgeIconType.fontAwesome
        let iconUrl = iconType.buildUrl(config: config)
        
        return UIImage.load(with: iconUrl)
    }
    
}
