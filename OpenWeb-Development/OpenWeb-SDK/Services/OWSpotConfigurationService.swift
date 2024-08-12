//
//  OWSpotConfigurationService.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 30/06/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
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
    fileprivate let _configWhichJustFetched = BehaviorSubject<(SPSpotConfiguration?, Error?)>(value: (nil, nil))
    fileprivate var configWhichJustFetched: Observable<(SPSpotConfiguration?, Error?)> {
        return _configWhichJustFetched
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
                        .flatMap { tuple -> Observable<SPSpotConfiguration?> in
                            if let error = tuple.1 {
                                // Throw error
                                return Observable.error(error)
                            } else if let config = tuple.0 {
                                // Return config
                                return Observable.just(config)
                            } else {
                                // Return nil observable to keep waiting
                                return Observable.just(nil)
                            }
                        }
                        .unwrap()
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
        let api: OWConfigurationAPI = self.servicesProvider.networkAPI().configuration

        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag

        // No need to dispose as we start with `just`
        Observable.just(())
            .do(onNext: { [weak self] _ in
                self?.isCurrentlyFetching.onNext(true)
                self?._configWhichJustFetched.onNext((nil, nil))
            })
            .flatMap {
                return api.fetchConfig(spotId: spotId)
                    .response
                    .take(1)
                    .do(onNext: { [weak self] config in
                        guard let self = self else { return  }
                        self.isCurrentlyFetching.onNext(false)
                        self._configWhichJustFetched.onNext((config, nil))
                        self.cacheConfigService[spotId] = config
                        self.setAdditionalStuff(forConfig: config)
                    }, onError: {[weak self] error in
                        guard let self = self else { return }
                        self.isCurrentlyFetching.onNext(false)
                        self._configWhichJustFetched.onNext((nil, error))
                    })
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    func setAdditionalStuff(forConfig config: SPSpotConfiguration) {
        // Brand color
        if let brandColorHex = config.initialization?.brandColor,
           let color = UIColor.color(from: brandColorHex) {
            OWColorPalette.shared.setColor(color, forType: .brandColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .brandColor, forThemeStyle: .dark)

            // Comments votes selected use the brand color if not customized.
            OWColorPalette.shared.setColor(color, forType: .voteUpSelectedColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .voteUpSelectedColor, forThemeStyle: .dark)

            OWColorPalette.shared.setColor(color, forType: .voteDownSelectedColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .voteDownSelectedColor, forThemeStyle: .dark)

            OWColorPalette.shared.setColor(color, forType: .voteUpUnselectedColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .voteUpUnselectedColor, forThemeStyle: .dark)

            OWColorPalette.shared.setColor(color, forType: .voteDownUnselectedColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .voteDownUnselectedColor, forThemeStyle: .dark)

            OWColorPalette.shared.setColor(color, forType: .voteDownUnselectedColor, forThemeStyle: .light)
            OWColorPalette.shared.setColor(color, forType: .voteDownUnselectedColor, forThemeStyle: .dark)
        }
    }
}
