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
    func sortTranslation(perOption option: OWSortOption) -> String
    func update(sortOption: OWSortOption, perPostId postId: OWPostId)
    func invalidateCache()
}

class OWSortDictateService: OWSortDictateServicing {
    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    
    fileprivate var mapper = BehaviorSubject<[OWPostId: OWSortOption]>(value: [:])
    
    fileprivate lazy var sharedMapper = {
       return mapper
            .share(replay: 1)
            .observe(on: MainScheduler.instance)
    }()
    
    init (servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
    }
    
    func sortOption(perPostId postId: OWPostId) -> Observable<OWSortOption> {
        return .empty()
    }
    
    func sortTranslation(perOption option: OWSortOption) -> String {
        return ""
    }
    
    func update(sortOption: OWSortOption, perPostId postId: OWPostId) {
        _ = mapper
            .take(1)
            .subscribe(onNext: { [weak self] mapping in
                guard let self = self else { return }
                var newMapping = mapping
                newMapping[postId] = sortOption
                self.mapper.onNext(newMapping)
            })
    }
    
    func invalidateCache() {
        mapper.onNext([:])
    }
}
