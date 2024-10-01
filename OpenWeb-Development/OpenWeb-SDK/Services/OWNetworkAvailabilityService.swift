//
//  OWNetworkAvailabilityService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 30/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Network
import RxSwift

protocol OWNetworkAvailabilityServicing {
    var networkAvailable: Observable<Bool> { get }
}

class OWNetworkAvailabilityService: OWNetworkAvailabilityServicing {
    static let shared = OWNetworkAvailabilityService()

    private var networkMonitor: NWPathMonitor
    private let networkAvailableSubject = BehaviorSubject<Bool>(value: true)
    var networkAvailable: Observable<Bool> {
        return networkAvailableSubject.asObservable()
            .distinctUntilChanged()
    }
    private let queue = DispatchQueue(label: "OWInternalNetworkAvailabilityQueue", qos: .background)

    private init() {
        networkMonitor = NWPathMonitor()

        networkMonitor.pathUpdateHandler = { [weak self] path in
            if let self {
                let isNetworkAvailable = path.status == .satisfied
                self.networkAvailableSubject.onNext(isNetworkAvailable)
            }
        }

        networkMonitor.start(queue: queue)
    }
}
