//
//  SubscriberBadgeService.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 01/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift


protocol SubscriberBadgeServicing {
    func badgeImage(model: OWSubscriberBadge) -> Observable<UIImage>
}

class SubscriberBadgeService: SubscriberBadgeServicing {
    
    fileprivate let defaultSubscriberBadgeBaseUrl: String = "\(APIConstants.fetchImageBaseURL)\(SPImageRequestConstants.cloudinaryIconParamString)\(SPImageRequestConstants.iconPathComponent)"

    fileprivate let customSubscriberBadgeBaseUrl: String = "\(APIConstants.cdnBaseURL)\(SPImageRequestConstants.iconsPathComponent)\(SPImageRequestConstants.customPathComponent)"
    
    fileprivate var iconUrl: URL?
    
    enum SubscriberBadgeIconType {
        case fontAwesome, custom
        func buildUrl(iconType: String, iconName: String, baseURL: String) -> URL? {
            switch(self) {
            case .fontAwesome:
                return URL(string:"\(baseURL)\(iconType)-\(iconName).png")
            case .custom:
                return URL(string:"\(baseURL)\(iconName).png")
            }
        }
    }
    
    func badgeImage(model: OWSubscriberBadge) -> Observable<UIImage> {
        
        if model.type == "custom" {
            iconUrl = SubscriberBadgeIconType.custom.buildUrl(
                iconType: model.type,
                iconName: model.name,
                baseURL: customSubscriberBadgeBaseUrl)
        } else {
            iconUrl = SubscriberBadgeIconType.fontAwesome.buildUrl(
                iconType: model.type,
                iconName: model.name,
                baseURL: defaultSubscriberBadgeBaseUrl)
        }
        
        return UIImage.load(with: iconUrl)
    }
    
}
