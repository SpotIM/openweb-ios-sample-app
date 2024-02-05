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

class OWNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    static let shared = OWNetworkAvailabilityService()

    fileprivate var networkMonitor: NWPathMonitor
    fileprivate let networkAvailableSubject = BehaviorSubject<Bool>(value: true)
    var networkAvailable: Observable<Bool> {
        return networkAvailableSubject.asObservable()
            .distinctUntilChanged()
    }
    fileprivate let queue = DispatchQueue(label: "OWInternalNetworkAvailabilityQueue", qos: .background)

    fileprivate init() {
        networkMonitor = NWPathMonitor()

        networkMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                let isNetworkAvailable = path.status == .satisfied
                self.networkAvailableSubject.onNext(isNetworkAvailable)
            }
        }

        networkMonitor.start(queue: queue)
    }
}
