//
//  OWUserSubscriberBadgeViewModel.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 26/01/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWUserSubscriberBadgeViewModelingInputs {
    func configureModel(_ model: OWSubscriberBadge)
}

protocol OWUserSubscriberBadgeViewModelingOutputs {
    var image: Observable<UIImage> { get }
    var isSubscriber: Bool { get }
}

protocol OWUserSubscriberBadgeViewModeling {
    var inputs: OWUserSubscriberBadgeViewModelingInputs { get }
    var outputs: OWUserSubscriberBadgeViewModelingOutputs { get }
}

class OWUserSubscriberBadgeViewModel: OWUserSubscriberBadgeViewModeling,
                                      OWUserSubscriberBadgeViewModelingInputs,
                                      OWUserSubscriberBadgeViewModelingOutputs {

    var inputs: OWUserSubscriberBadgeViewModelingInputs { return self }
    var outputs: OWUserSubscriberBadgeViewModelingOutputs { return self }
    
    fileprivate var model = BehaviorSubject<OWSubscriberBadge?>(value: nil)
    
    fileprivate let defaultSubscriberBadgeBaseUrl: String = "\(APIConstants.fetchImageBaseURL)\(SPImageRequestConstants.cloudinaryIconParamString)\(SPImageRequestConstants.iconPathComponent)"

    fileprivate let customSubscriberBadgeBaseUrl: String = "\(APIConstants.cdnBaseURL)\(SPImageRequestConstants.iconsPathComponent)\(SPImageRequestConstants.customPathComponent)"

    
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
    
    var iconUrl: URL?
    
    init (_ model: OWSubscriberBadge?) {
        if let subscriberBadgeModel = model {
            configureModel(subscriberBadgeModel)
        }
    }
    
    lazy var image: Observable<UIImage> = {
        return UIImage.load(with: iconUrl)
    }()
    
    lazy var isSubscriber: Bool = {
        return SPUserSessionHolder.session.user?.ssoData?.isSubscriber ?? false
    }()
    
    func configureModel(_ model: OWSubscriberBadge) {
        self.model.onNext(model)
        
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
    }
}
