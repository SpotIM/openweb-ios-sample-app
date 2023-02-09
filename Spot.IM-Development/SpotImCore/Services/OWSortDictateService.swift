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
    func sortTextPresentation(perOption sortOption: OWSortOption) -> String
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
        return .empty()
    }
    
    func sortTextPresentation(perOption sortOption: OWSortOption) -> String {
        guard let sortCustomizerInternal = sortCustomizer as? OWSortingCustomizationsInternal else {
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
                var newMapping = mapping
                newMapping[postId] = sortOption
                self.mapper.onNext(newMapping)
            })
    }
    
    func invalidateCache() {
        mapper.onNext([:])
    }
}
