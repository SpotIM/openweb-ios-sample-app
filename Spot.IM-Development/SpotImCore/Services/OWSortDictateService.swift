//
//  OWSortDictateService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 09/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSortDictateServicing {
    func sortOption(perPostId postId: OWPostId) -> Observable<OWSortOption>
    func sortTextTitle(perOption sortOption: OWSortOption) -> String
    func update(sortOption: OWSortOption, perPostId postId: OWPostId)
    func invalidateCache()
}

class OWSortDictateService: OWSortDictateServicing {
    
    fileprivate typealias OWSkipAndMapping = Observable<(Bool, [OWPostId: OWSortOption])>
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    
    fileprivate let mapper = BehaviorSubject<[OWPostId: OWSortOption]>(value: [:])
    fileprivate lazy var sharedMapper = {
        return mapper
            .share(replay: 1)
            .observe(on: MainScheduler.instance)
    }()
    
    fileprivate lazy var sortCustomizer: OWSortingCustomizations = {
        return OpenWeb.manager
            .ui
            .customizations
            .sorting
    }()
    
    init (servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
    }

    func sortOption(perPostId postId: OWPostId) -> Observable<OWSortOption> {
        return mapper
            .take(1)
            .flatMap { mapping -> OWSkipAndMapping in
                // 1. Check if we already have a sort option for the postId in the mapper
                
                guard let _ = mapping[postId] else {
                    return Observable.just((false, mapping))
                }

                // We already have a mapping for the required sorting option per this postId, skip next step
                return Observable.just((true, mapping))
            }
            .flatMap { [weak self] skipAndMapper -> Observable<Void> in
                // 2. Inject sort option to the mapper from local or from server config according to `OWInitialSortStrategy`
                
                guard let self = self else { return Observable.empty() }
                let shouldSkip = skipAndMapper.0
                let mapping = skipAndMapper.1
                
                if shouldSkip {
                    // Finish flatMap, skipping this entire step
                    return Observable.just(())
                } else if case OWInitialSortStrategy.use(sortOption: let sortOption) = self.sortCustomizer.initialOption {
                    // Injecting local initial sorting to the mapper
                    self.inject(toPostId: postId, sortOption: sortOption, fromOriginalMapping: mapping)
                    // Finish flatMap
                    return Observable.just(())
                } else {
                    // We will inject to the mapper the required initial sorting from the server config
                    return self.servicesProvider.spotConfigurationService()
                        .config(spotId: OpenWeb.manager.spotId)
                        .take(1)
                        .map { config in
                            guard let oldSortType = config.initialization?.sortBy else {
                                // Should set the initial config from the server, however there isn't any.
                                // Using the default one `.best` in such case
                                return OWSortOption.default
                            }

                            let sortOption = OWSortOption(fromOldSortType: oldSortType)
                            return sortOption
                        }
                        .do(onNext: { [weak self] sortOption in
                            guard let self = self else { return }
                            // Injecting server initial sorting to the mapper
                            self.inject(toPostId: postId, sortOption: sortOption, fromOriginalMapping: mapping)
                        })
                        .voidify()
                }
            }
            .flatMap { [weak self] _ -> Observable<[OWPostId: OWSortOption]> in
                // 3. Returning sharedMapper after we sure there is a sort option for the postId
                
                guard let self = self else { return .empty() }
                return self.sharedMapper
            }
            .map { [weak self] mapping -> OWSortOption in
                // 4. Mapping to the appropriate sort option per postId
                
                guard let self = self else { return .best }
                guard let sortOption = mapping[postId] else {
                    // This should never happen
                    let logMessage = "Failed to get the appropriate sort option for postId: \(postId), recovering by passing `.best` "
                    self.servicesProvider.logger().log(level: .error, logMessage)
                    return OWSortOption.default
                }

                return sortOption
            }
            .distinctUntilChanged()
        }
    
    func sortTextTitle(perOption sortOption: OWSortOption) -> String {
        guard let sortCustomizerInternal = sortCustomizer as? OWSortingCustomizationsInternal else {
            let logMessage = "Failed casting `OWSortingCustomizer` to `OWSortingCustomizationsInternal` protocol, recovering by returning the default title for sort option"
            servicesProvider.logger().log(level: .medium, logMessage)
            return sortOption.title
        }
        
        let customizedTitleType = sortCustomizerInternal.customizedTitle(forOption: sortOption)
        guard case .customized(title: let customizedTitle) = customizedTitleType else {
            return sortOption.title
        }
        
        return customizedTitle
    }
    
    func update(sortOption: OWSortOption, perPostId postId: OWPostId) {
        _ = mapper
            .take(1)
            .subscribe(onNext: { [weak self] mapping in
                guard let self = self else { return }
                self.inject(toPostId: postId, sortOption: sortOption, fromOriginalMapping: mapping)
            })
    }
    
    func invalidateCache() {
        mapper.onNext([:])
    }
}

fileprivate extension OWSortDictateService {
    func inject(toPostId postId: OWPostId,
                sortOption: OWSortOption,
                fromOriginalMapping originalMapping: [OWPostId: OWSortOption]) {
        var newMapping = originalMapping
        newMapping[postId] = sortOption
        self.mapper.onNext(newMapping)
    }
}
