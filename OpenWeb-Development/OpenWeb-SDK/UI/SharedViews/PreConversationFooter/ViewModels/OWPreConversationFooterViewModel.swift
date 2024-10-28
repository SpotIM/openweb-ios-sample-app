//
//  OWPreConversationFooterViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationFooterViewModelingInputs {
    var termsTap: PublishSubject<Void> { get }
    var privacyTap: PublishSubject<Void> { get }
    var poweredByOWTapped: PublishSubject<Void> { get }
}

protocol OWPreConversationFooterViewModelingOutputs {
    var urlClickedOutput: Observable<URL> { get }
    var termsTapped: Observable<Void> { get }
    var privacyTapped: Observable<Void> { get }
}

protocol OWPreConversationFooterViewModeling {
    var inputs: OWPreConversationFooterViewModelingInputs { get }
    var outputs: OWPreConversationFooterViewModelingOutputs { get }
}

class OWPreConversationFooterViewModel: OWPreConversationFooterViewModeling, OWPreConversationFooterViewModelingInputs, OWPreConversationFooterViewModelingOutputs {
    var inputs: OWPreConversationFooterViewModelingInputs { return self }
    var outputs: OWPreConversationFooterViewModelingOutputs { return self }

    private let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    private lazy var mobileSdkConfigObservable: Observable<SPConfigurationSDKStatus> = {
        servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { config -> SPConfigurationSDKStatus? in
                return config.mobileSdk
            }
            .unwrap()
    }()

    var termsTap = PublishSubject<Void>()
    var termsTapped: Observable<Void> { // This is used for OWViewActionCallbacks
        return termsTap
            .asObservable()
    }

    var _openTerms: Observable<URL> {
        return termsTap
            .asObserver()
            .withLatestFrom(mobileSdkConfigObservable) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebTermsUrl)
            }
            .unwrap()
    }

    var privacyTap = PublishSubject<Void>()
    var privacyTapped: Observable<Void> { // This is used for OWViewActionCallbacks
        return privacyTap
            .asObservable()
    }

    var _openPrivacy: Observable<URL> {
        return privacyTap
            .asObserver()
            .withLatestFrom(mobileSdkConfigObservable) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebPrivacyUrl)
            }
            .unwrap()
    }

    var poweredByOWTapped = PublishSubject<Void>()
    var _openOWWebsite: Observable<URL> {
        return poweredByOWTapped
            .asObserver()
            .withLatestFrom(mobileSdkConfigObservable) { _, sdkConfig -> URL? in
                return URL(string: sdkConfig.openwebWebsiteUrl)
            }
            .unwrap()
    }

    var urlClickedOutput: Observable<URL> {
        return Observable.merge(_openTerms, _openPrivacy, _openOWWebsite)
    }
}
