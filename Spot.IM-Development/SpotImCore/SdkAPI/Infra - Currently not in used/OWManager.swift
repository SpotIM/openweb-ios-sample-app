//
//  OWManager.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Will be a public protocol which expose the different layers of the manager
protocol OWManagerProtocol {
    
}

// Internal protocol
protocol OWManagerInternalProtocol: AnyObject  {
    var spotConfig: Observable<SPSpotConfiguration> { get }
}

class OWManager: OWManagerProtocol, OWManagerInternalProtocol {
    
    // Singleton, will be public access once a new API will be ready.
    // Publishers and SDK consumers will basically interact with the manager / public encapsulation of it.
    static let manager = OWManager()
    
    // Memebers variables
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _spotConfig = BehaviorSubject<SPSpotConfiguration?>(value: nil)
    
    private init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

extension OWManager {
    var spotConfig: Observable<SPSpotConfiguration> {
        return _spotConfig
            .unwrap()
            .asObservable()
    }
}
