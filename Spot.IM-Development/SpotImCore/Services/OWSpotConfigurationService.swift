//
//  OWSpotConfigurationService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 30/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSpotConfigurationServicing {
    func config(spotId: OWSpotId) -> Observable<SPSpotConfiguration>
    func spotChanged(spotId: OWSpotId)
}

class OWSpotConfigurationService: OWSpotConfigurationServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    // Cache config for half an hour
    fileprivate let cacheConfigService = OWCacheService<OWSpotId, SPSpotConfiguration>(expirationStrategy: .time(lifetime: 30 * 60))
    fileprivate var disposeBag: DisposeBag? = DisposeBag()
    fileprivate let isCurrentlyFetching = BehaviorSubject<Bool>(value: false)
    fileprivate let _configWhichJustFetched = BehaviorSubject<SPSpotConfiguration?>(value: nil)
    fileprivate var configWhichJustFetched: Observable<SPSpotConfiguration> {
        return _configWhichJustFetched
            .unwrap()
            .share(replay: 0) // New subscribers will get only elements which emits after their subscription
    }
    
    init (servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
    }
    
    func config(spotId: OWSpotId) -> Observable<SPSpotConfiguration> {
        if let cacheConfig = cacheConfigService[spotId] {
            // Return cache configuration
            return .just(cacheConfig)
        } else {
            return isCurrentlyFetching
                .take(1)
                .flatMap { [weak self] isFetching -> Observable<SPSpotConfiguration> in
                    guard let self = self else { return .empty() }
                    if !isFetching {
                        self.fetchConfig(spotId: spotId)
                    }
                    
                    // This way if other calls to this functions are being done before the network request finish, we won't send new requests
                    return self.configWhichJustFetched
                        .take(1)
                }
        }
    }
    
    func spotChanged(spotId: OWSpotId) {
        // Dispose any current network requests if exist
        disposeBag = nil
        isCurrentlyFetching.onNext(false)
        // Start fetching config for the new spotId as we will obviously need it
        fetchConfig(spotId: spotId)
    }
}

fileprivate extension OWSpotConfigurationService {
    func fetchConfig(spotId: OWSpotId) {
        // Fetch from API
        let api: OWConfigurationAPI = self.servicesProvider.netwokAPI().configuration
        
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        
        // No need to dispose as we start with `just`
        Observable.just(())
            .do(onNext: { [weak self] _ in
                self?.isCurrentlyFetching.onNext(true)
            })
            .flatMap {
                return api.fetchConfig(spotId: spotId)
                    .response
                    .take(1)
                    .do(onNext: { [weak self] config in
                        guard let self = self else { return  }
                        self.isCurrentlyFetching.onNext(false)
                        self._configWhichJustFetched.onNext(config)
                        self.cacheConfigService[spotId] = config
                        self.setAdditionalStuff(forConfig: config)
                    }, onError: {[weak self] error in
                        guard let self = self else { return  }
                        self.isCurrentlyFetching.onNext(false)
                        self._configWhichJustFetched.onError(error)
                    })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func setAdditionalStuff(forConfig config: SPSpotConfiguration) {
        if let color = UIColor.color(with: config.initialization?.brandColor) {
            OWColorPalette.shared.setColor(color, forType: .brandColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .brandColor, forThemeStyle: .dark)
        }
    }
}
