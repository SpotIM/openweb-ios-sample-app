//
//  OWSubscriberBadgeService.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 01/02/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSubscriberBadgeServicing {
    func badgeImage(config: OWSubscriberBadgeConfiguration) -> Observable<UIImage>
}

class OWSubscriberBadgeService: OWSubscriberBadgeServicing {

    fileprivate struct URLS {
        static let subscriberBadgeBaseUrl: String = "\(APIConstants.cdnBaseURL)\(SPImageRequestConstants.iconsPathComponent)"
        static let subscriberBadgeFontAwesomeBaseUrl: String = "\(subscriberBadgeBaseUrl)\(SPImageRequestConstants.fontAwesomePathComponent)\(SPImageRequestConstants.fontAwesomeVersionPathComponent)"
    }

    fileprivate enum OWSubscriberBadgeIconType: String {
        case regular = "fa-regular"
        case solid = "fa-solid"
        case brands = "fa-brands"
        case light = "fa-light"
        case custom

        func buildUrl(config: OWSubscriberBadgeConfiguration) -> URL {
            switch(self) {
            case .regular:
                return URL(string: "\(URLS.subscriberBadgeFontAwesomeBaseUrl)regular/\(config.name).png")!
            case .solid:
                return URL(string: "\(URLS.subscriberBadgeFontAwesomeBaseUrl)solid/\(config.name).png")!
            case .brands:
                return URL(string: "\(URLS.subscriberBadgeFontAwesomeBaseUrl)brands/\(config.name).png")!
            case .light:
                return URL(string: "\(URLS.subscriberBadgeFontAwesomeBaseUrl)light/\(config.name).png")!
            case .custom:
                return URL(string: "\(URLS.subscriberBadgeBaseUrl)\(SPImageRequestConstants.customPathComponent)\(config.name).png")!
            }
        }
    }

    func badgeImage(config: OWSubscriberBadgeConfiguration) -> Observable<UIImage> {

        let iconType = OWSubscriberBadgeIconType(rawValue: config.type) ?? OWSubscriberBadgeIconType.custom
        let iconUrl = iconType.buildUrl(config: config)

        return UIImage.load(with: iconUrl)
    }
}
