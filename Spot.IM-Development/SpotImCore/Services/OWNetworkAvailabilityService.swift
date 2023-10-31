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
    var networkStatus: Observable<Bool> { get }
}

// Since OWInternalNetworkAvailabilityService is available from iOS 12 only, we created a wrapper
class OWNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    var networkStatus: Observable<Bool> {
        if #available(iOS 12.0, *) {
            return OWInternalNetworkAvailabilityService.shared.networkStatus
        } else {
            return Observable.just(true)
        }
    }
}

@available(iOS 12.0, *)
class OWInternalNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    static let shared = OWInternalNetworkAvailabilityService()

    private var networkMonitor: NWPathMonitor
    private let networkStatusSubject = BehaviorSubject<Bool>(value: true)
    var networkStatus: Observable<Bool> {
        return networkStatusSubject.asObservable()
            .distinctUntilChanged()
    }

    private init() {
        networkMonitor = NWPathMonitor()

        networkMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                let isNetworkAvailable = path.status == .satisfied
                self.networkStatusSubject.onNext(isNetworkAvailable)
            }
        }

        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
    }
}
