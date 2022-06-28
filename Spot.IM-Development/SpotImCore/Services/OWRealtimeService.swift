//
//  OWRealtimeService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 28/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeServicing {
    func startFetchingData(postId: String)
    func stopFetchingData()
}

class OWRealtimeService: OWRealtimeServicing {
    fileprivate unowned let manager: OWManagerInternalProtocol
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let currentPostId = BehaviorSubject<String?>(value: nil)
    fileprivate let isCurrentlyFetching = BehaviorSubject<Bool>(value: false)
    
    init (manager: OWManagerInternalProtocol = OWManager.shared,
          servicesProvider: OWSharedServicesProviding) {
        self.manager = manager
        self.servicesProvider = servicesProvider
    }
    
    func startFetchingData(postId: String) {
        _ = manager.spotConfig
            .take(1)
            .flatMap { [weak self] config -> Observable<String?> in
                guard let self = self,
                      let realtimeEnabled = config.mobileSdk.realtimeEnabled,
                      realtimeEnabled else {
                          self?.servicesProvider.logger().log(level: .verbose, "Realtime flag in the configuration is not enabled, so the realtime service will not fetch data")
                          return .empty()
                      }
                return self.currentPostId
                    .take(1)
            }
            .flatMap { [weak self] currentPostId -> Observable<Bool> in
                guard let self = self else { return .empty() }
                guard let currPostId = currentPostId else {
                    // First time we call `startFetchingData`
                    self.currentPostId.onNext(postId)
                    return .just(true)
                }
                guard currPostId == postId else {
                    // A different postId. Let's first stop the realtime service from fetching data
                    self.stopFetchingData()
                    return .just(true)
                }
                
                // We should fetch realtime data for the same `postId` which we already set.
                // Let's do so only if we currently not already fetching data.
                return self.isCurrentlyFetching
                    .take(1)
                    .map { !$0 } // Reversing
            }
            .filter { $0 == true } // Continue only if we should fetch the data
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
            })
    }
    
    func stopFetchingData() {
        
    }
}

fileprivate extension OWRealtimeService {
    func startFetchingData() {
        
    }
}
