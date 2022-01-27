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
    var image: UIImage { get }
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
    
    fileprivate let subscriberBadgeBaseUrl: String = "\(APIConstants.fetchImageBaseURL) \(SPImageRequestConstants.cloudinaryIconParamString) \(SPImageRequestConstants.iconPathComponent)"
    
    var iconUrl: Observable<URL?> {
        return model
            .unwrap()
            .map {
                return URL(
                    string: "\(self.subscriberBadgeBaseUrl) \($0.type) - \($0.name) .png"
                    )
            }
    }
    
    init (_ model: OWSubscriberBadge) {
        configureModel(model)
    }
    
    lazy var image: UIImage = { return UIImage() }()
    
    lazy var isSubscriber: Bool = {
        return SPUserSessionHolder.session.user?.ssoData?.isSubscriber ?? false
    }()
    
    func configureModel(_ model: OWSubscriberBadge) {
        self.model.onNext(model)
    }
    
}
