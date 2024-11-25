//
//  OWManager.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
@_exported import OpenWebSDKAdapter

// Internal protocol
protocol OWManagerInternalProtocol: AnyObject {
    var currentSpotId: Observable<OWSpotId> { get }
    var currentPostId: Observable<OWPostId> { get }
    var postId: OWPostId? { get set }
}

class OWManager: OWManagerProtocol, OWManagerInternalProtocol {
    // Singleton, will be public access once a new API will be ready.
    // Publishers and SDK consumers will basically interact with the manager / public encapsulation of it.
    static let manager = OWManager()

    // Memebers variables
    private let disposeBag = DisposeBag()
    private let servicesProvider: OWSharedServicesProviding
    private let _currentSpotId = BehaviorSubject<OWSpotId?>(value: nil)
    private let _currentPostId = BehaviorSubject<OWPostId?>(value: nil)
    private var _currentNonRxSpotId: OWSpotId?
    private var _currentNonRxPostId: OWPostId?

    // Layers
    let analyticsLayer: OWAnalytics
    let uiLayer: OWUI
    let monetizationLayer: OWMonetization
    let authenticationLayer: OWAuthentication
    let helpersLayer: OWHelpers

    // Environment (only available for BETA app)
    var environment: OWNetworkEnvironmentType = .production {
        didSet {
            OWEnvironment.set(environmentType: environment)
            // When env is set we must reset networkApi
            self.servicesProvider.configure.resetNetworkEnvironment()
        }
    }

    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
                 analyticsLayer: OWAnalytics = OWAnalyticsLayer(),
                 uiLayer: OWUI = OWUILayer(),
                 monetizationLayer: OWMonetization = OWMonetizationLayer(),
                 authenticationLayer: OWAuthentication = OWAuthenticationLayer(),
                 helpersLayer: OWHelpers = OWHelpersLayer()) {
        self.servicesProvider = servicesProvider
        self.analyticsLayer = analyticsLayer
        self.uiLayer = uiLayer
        self.monetizationLayer = monetizationLayer
        self.authenticationLayer = authenticationLayer
        self.helpersLayer = helpersLayer
        setupObservers()
    }
}

// Will be public extension
extension OWManager {
    var spotId: OWSpotId {
        get {
           return _currentNonRxSpotId ?? ""
        }
        set(newSpotId) {
            _currentNonRxSpotId = newSpotId
            _currentSpotId.onNext(newSpotId)
        }
    }

    var postId: OWPostId? {
        get {
           return _currentNonRxPostId
        }
        set(newPostId) {
            let encodedPostId = newPostId?.encoded
            _currentNonRxPostId = encodedPostId
            _currentPostId.onNext(encodedPostId)
        }
    }
}

// Internal extension
extension OWManager {
    var currentSpotId: Observable<OWSpotId> {
        return _currentSpotId
            .unwrap()
            .asObservable()
    }

    var currentPostId: Observable<OWPostId> {
        return _currentPostId
            .unwrap()
            .asObservable()
            .distinctUntilChanged()
    }
}

// Extension with access only inside this file and for the OWManager class
private extension OWManager {
    func setupObservers() {
        currentPostId
            .skip(1)
            .subscribe(onNext: { [weak self] _ in
                // PostId was re-set to another postId
                guard let self else { return }
                self.resetPostId()
            })
            .disposed(by: disposeBag)

        currentSpotId
            .take(1)
            .subscribe(onNext: { [weak self] spotId in
                // SpotId was set for the first time
                guard let self else { return }
                self.servicesProvider.configure.set(spotId: spotId)
            })
            .disposed(by: disposeBag)

        // SpotId was re-set to another spotId
        currentSpotId
            .scan((false, ""), accumulator: { result, newSpotId in
                guard !result.1.isEmpty else {
                    // First time the scan called or a case in which spotId set to empty string by the publisher
                    return (false, newSpotId)
                }

                if result.1 != newSpotId {
                    return (true, newSpotId)
                } else {
                    // Same spotId, practically we should never arrived here as we added `distinctUntilChanged` to `currentSpotId` observable
                    return (false, newSpotId)
                }
            })
            .filter { $0.0 } // Continue only if scan return `true` in the first variable
            .map { $0.1 } // Map back to the spotId
            .subscribe(onNext: { [weak self] spotId in
                // SpotId was re-set to another spotId
                guard let self else { return }
                self.resetSpotId()
                self.servicesProvider.configure.change(spotId: spotId)
            })
            .disposed(by: disposeBag)

        // SpotId was re-set to the same spotId
        currentSpotId
            .scan((false, ""), accumulator: { result, newSpotId in
                guard !result.1.isEmpty else {
                    // First time the scan called or a case in which spotId set to empty string by the publisher
                    return (false, newSpotId)
                }

                if result.1 == newSpotId {
                    return (true, newSpotId)
                } else {
                    // Same spotId, practically we should never arrived here as we added `distinctUntilChanged` to `currentSpotId` observable
                    return (false, newSpotId)
                }
            })
            .filter { $0.0 } // Continue only if scan return `true` in the first variable
            .map { $0.1 } // Map back to the spotId
            .subscribe(onNext: { [weak self] spotId in
                // SpotId was re-set to the same spotId
                guard let self else { return }
                self.resetSpotId()
                self.servicesProvider.spotConfigurationService().spotChanged(spotId: spotId)
            })
            .disposed(by: disposeBag)

        currentPostId
            .subscribe(onNext: { [weak self] postId in
                self?.servicesProvider
                    .activeArticleService()
                    .updatePost(postId)
            })
            .disposed(by: disposeBag)
    }

    // Things to clear / reset each time the spotId reset (even if the same spotId set again - usually the use case will be from our Sample App).
    func resetSpotId() {
        if let customizations = self.uiLayer.customizations as? OWCustomizationsInternalProtocol {
            customizations.clearCallbacks()
            customizations.clearColorsCustomizations()
        }

        if let analytics = self.analyticsLayer as? OWAnalyticsInternalProtocol {
            analytics.clearCallbacks()
        }

        OWColorPalette.shared.initiateColors()
    }

    // Things to clear / reset each time the postId changed
    func resetPostId() {
        self.servicesProvider.realtimeService()
            .reset()
    }
}
