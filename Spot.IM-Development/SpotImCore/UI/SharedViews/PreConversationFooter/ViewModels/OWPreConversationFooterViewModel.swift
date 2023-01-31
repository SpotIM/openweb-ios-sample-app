//
//  OWPreConversationFooterViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationFooterViewModelingInputs {
    var termsTapped: PublishSubject<Void> { get }
    var privacyTapped: PublishSubject<Void> { get }
    var poweredByOWTapped: PublishSubject<Void> { get }
}

protocol OWPreConversationFooterViewModelingOutputs {
    var openUrl: Observable<URL> { get }
}

protocol OWPreConversationFooterViewModeling {
    var inputs: OWPreConversationFooterViewModelingInputs { get }
    var outputs: OWPreConversationFooterViewModelingOutputs { get }
}

class OWPreConversationFooterViewModel: OWPreConversationFooterViewModeling, OWPreConversationFooterViewModelingInputs, OWPreConversationFooterViewModelingOutputs {
    var inputs: OWPreConversationFooterViewModelingInputs { return self }
    var outputs: OWPreConversationFooterViewModelingOutputs { return self }
        
    fileprivate var mobileSdkConfig: Observable<SPConfigurationSDKStatus> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationSDKStatus? in
                return config.mobileSdk
            }
            .unwrap()
    }
    
    var termsTapped = PublishSubject<Void>()
    var _openTerms: Observable<URL> {
        return termsTapped
            .asObserver()
            .withLatestFrom(mobileSdkConfig) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebTermsUrl)
            }
            .unwrap()
    }
    
    var privacyTapped = PublishSubject<Void>()
    var _openPrivacy: Observable<URL> {
        return privacyTapped
            .asObserver()
            .withLatestFrom(mobileSdkConfig) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebPrivacyUrl)
            }
            .unwrap()
    }
    
    var poweredByOWTapped = PublishSubject<Void>()
    var _openOWWebsite: Observable<URL> {
        return poweredByOWTapped
            .asObserver()
            .withLatestFrom(mobileSdkConfig) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebWebsiteUrl)
            }
            .unwrap()
    }
    
    var openUrl: Observable<URL> {
        return Observable.merge(_openTerms, _openPrivacy, _openOWWebsite)
    }
}
