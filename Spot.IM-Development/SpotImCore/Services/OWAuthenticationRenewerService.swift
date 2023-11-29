//
//  OWAuthenticationRenewerService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 23/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWAuthenticationRenewerServicing {}

class OWAuthenticationRenewerService: OWAuthenticationRenewerServicing {
    fileprivate let appLifeCycle: OWRxAppLifeCycleProtocol
    fileprivate let netwokAPI: OWNetworkAPIProtocol
    fileprivate let disposeBag = DisposeBag()

    init(appLifeCycle: OWRxAppLifeCycleProtocol = OWSharedServicesProvider.shared.appLifeCycle(),
         netwokAPI: OWNetworkAPIProtocol = OWSharedServicesProvider.shared.netwokAPI()) {
        self.appLifeCycle = appLifeCycle
        self.netwokAPI = netwokAPI

        setupObservers()
    }
}

fileprivate extension OWAuthenticationRenewerService {
    func setupObservers() {
        appLifeCycle.willEnterForeground
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                // The call to get the user data is enough to trigger the whole renew auth process in case it's needed
                return self.netwokAPI.user
                    .userData()
                    .response
                    .voidify()
            }
            .subscribe()
            .disposed(by: disposeBag)
    }
}
