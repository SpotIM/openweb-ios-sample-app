//
//  OWNetworkAvailabilityService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 30/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import Network
import RxSwift

protocol OWNetworkAvailabilityServicing {
    var networkAvailable: Observable<Bool> { get }
}

// Since OWInternalNetworkAvailabilityService is available from iOS 12 only, we created a wrapper
class OWNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    var networkAvailable: Observable<Bool> {
        if #available(iOS 12.0, *) {
            return OWInternalNetworkAvailabilityService.shared.networkAvailable
        } else {
            return Observable.just(true)
        }
    }
}

@available(iOS 12.0, *)
class OWInternalNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    static let shared = OWInternalNetworkAvailabilityService()

    fileprivate var networkMonitor: NWPathMonitor
    fileprivate let networkAvailableSubject = BehaviorSubject<Bool>(value: true)
    var networkAvailable: Observable<Bool> {
        return networkAvailableSubject.asObservable()
            .distinctUntilChanged()
    }

    fileprivate init() {
        networkMonitor = NWPathMonitor()

        networkMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                let isNetworkAvailable = path.status == .satisfied
                self.networkAvailableSubject.onNext(isNetworkAvailable)
            }
        }

        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
