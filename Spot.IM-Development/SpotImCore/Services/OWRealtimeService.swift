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
    func startFetchingData(postId: OWPostId)
    func stopFetchingData()
    var realtimeData: Observable<RealTimeModel> { get }
}

class OWRealtimeService: OWRealtimeServicing {
    fileprivate unowned let manager: OWManagerInternalProtocol
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate let scheduler: SchedulerType
    fileprivate let currentPostId = BehaviorSubject<OWPostId?>(value: nil)
    fileprivate let isCurrentlyFetching = BehaviorSubject<Bool>(value: false)
    fileprivate var disposeBag: DisposeBag?
    
    init (manager: OWManagerInternalProtocol = OWManager.manager,
          servicesProvider: OWSharedServicesProviding,
          scheduler: SchedulerType = SerialDispatchQueueScheduler(qos: .utility, internalSerialQueueName: "OpenWebSDKRealtimeServiceQueue")) {
        self.manager = manager
        self.servicesProvider = servicesProvider
        self.scheduler = scheduler
    }
    
    let _realtimeData = BehaviorSubject<RealTimeModel?>(value: nil)
    var realtimeData: Observable<RealTimeModel> {
        return _realtimeData
            .unwrap()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .share(replay: 1) // Send the last element to new subscribers immediately
    }
    
    func startFetchingData(postId: OWPostId) {
        _ = manager.currentSpotId
            .take(1)
            .observe(on: self.scheduler) // Do the rest of the Rx chain on this class scheduler
            .flatMap { [weak self] spotId -> Observable<SPSpotConfiguration> in
                guard let self = self else { return .empty()}
                return self.servicesProvider.spotConfigurationService().config(spotId: spotId)
                    .take(1)
            }
            .flatMap { [weak self] config -> Observable<String?> in
                // Continue only if real time service is enabled according to the config
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
                // Check if the provided postId is the current one we working on or something else
                guard let self = self else { return .empty() }
                guard let currPostId = currentPostId else {
                    // First time we call `startFetchingData`
                    self.currentPostId.onNext(postId)
                    return .just(true)
                }
                guard currPostId == postId else {
                    // A different postId. Let's first stop the realtime service from fetching data
                    self.stopFetchingData()
                    self.currentPostId.onNext(postId)
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
                self.fetchData()
            })
    }
    
    func stopFetchingData() {
        isCurrentlyFetching.onNext(false)
        // Dispose realtime subscription
        disposeBag = nil
    }
}

fileprivate extension OWRealtimeService {
    func fetchData() {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        
        // Start with the currentPostId which in this state must contain a valid postId
        currentPostId
            .unwrap()
            .observe(on: self.scheduler) // Do the rest of the Rx chain on this class scheduler
            .flatMap { [weak self] postId -> Observable<RealTimeModel> in
                guard let self = self else { return .empty() }
                let api: OWRealtimeAPI = self.servicesProvider.netwokAPI().realtime
                // Fetch from API
                return api.fetchData(fullConversationId: "\(OWManager.manager.spotId)_\(postId)")
                    .response
            }
            .do(onNext: { [weak self] _ in
                // Emit event to 'flag' currently fetching
                self?.isCurrentlyFetching.onNext(true)
            })
            // Use retry in case there is temporarily no network or any other issue
            .exponentialRetry(maxAttempts: 3, millisecondsDelay: 1000, scheduler: self.scheduler)
            .do(onNext: { [weak self] realtimeDataModel in
                // Emit event to consumers of realtime data
                self?._realtimeData.onNext(realtimeDataModel)
            })
            .flatMap { realtimeDataModel -> Observable<Void> in
                let secondsOffset = realtimeDataModel.nextFetch - realtimeDataModel.timestamp
                // Start delay for the next fetch
                return .just(())
                    .delay(.seconds(secondsOffset), scheduler: self.scheduler)
            }
            .subscribe(onNext: { [weak self] _ in
                // Fetch the next data
                self?.fetchData()
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.servicesProvider.logger().log(level: .error, "Realtime service failed after retry mechanisem with error: \(error)")
                self.stopFetchingData()
            })
            .disposed(by: disposeBag)
    }
}
