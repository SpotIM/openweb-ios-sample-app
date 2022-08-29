//
//  OWManager.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Internal protocol
protocol OWManagerInternalProtocol: AnyObject  {
    var currentSpotId: Observable<OWSpotId> { get }
    var currentPostId: Observable<OWPostId> { get }
    var postId: OWPostId? { get }
}

class OWManager: OWManagerProtocol, OWManagerInternalProtocol {
    
    // Singleton, will be public access once a new API will be ready.
    // Publishers and SDK consumers will basically interact with the manager / public encapsulation of it.
    static let manager = OWManager()
    
    // Memebers variables
    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding
    let analyticsLayer: OWAnalytics
    let uiLayer: OWUI
    fileprivate let _currentSpotId = BehaviorSubject<OWSpotId?>(value: nil)
    fileprivate let _currentPostId = BehaviorSubject<OWPostId?>(value: nil)
    fileprivate var _currentNonRxSpotId: OWSpotId? = nil
    fileprivate var _currentNonRxPostId: OWPostId? = nil
    
    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
                 analyticsLayer: OWAnalytics = OWAnalyticsLayer(),
                 uiLayer: OWUI = OWUILayer()) {
        self.servicesProvider = servicesProvider
        self.analyticsLayer = analyticsLayer
        self.uiLayer = uiLayer
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
            _currentNonRxPostId = newPostId
            _currentPostId.onNext(newPostId)
        }
    }
}
    
// Internal extension
extension OWManager {
    var currentSpotId: Observable<OWSpotId> {
        return _currentSpotId
            .unwrap()
            .asObservable()
            .distinctUntilChanged()
    }
    
    var currentPostId: Observable<OWPostId> {
        return _currentPostId
            .unwrap()
            .asObservable()
            .distinctUntilChanged()
    }
}

// Extension with access only inside this file and for the OWManager class
fileprivate extension OWManager {
    func setupObservers() {
        currentSpotId
            .take(1)
            .subscribe(onNext: { [weak self] spotId in
                // SpotId was set for the first time
                guard let self = self else { return }
                self.servicesProvider.configure.set(spotId: spotId)
            })
            .disposed(by: disposeBag)
        
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
                guard let self = self else { return }
                self.servicesProvider.configure.change(spotId: spotId)
            })
            .disposed(by: disposeBag)
    }
}
