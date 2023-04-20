//
//  OWOnlineViewingUsersCounterViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWOnlineViewingUsersCounterViewModelingInputs { }

protocol OWOnlineViewingUsersCounterViewModelingOutputs {
    var viewingCount: Observable<String> { get }
}

protocol OWOnlineViewingUsersCounterViewModeling {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { get }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { get }
}

class OWOnlineViewingUsersCounterViewModel: OWOnlineViewingUsersCounterViewModeling,
                                                OWOnlineViewingUsersCounterViewModelingInputs,
                                                OWOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var model = BehaviorSubject<RealTimeOnlineViewingUsersModel?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }

    lazy var viewingCount: Observable<String> = {
        guard let postId = OWManager.manager.postId else { return .empty() }

        let realtimeService = OWSharedServicesProvider.shared.realtimeService()
        return realtimeService.realtimeData
            .map { realtimeData in
                try? realtimeData.data?.onlineViewingUsersCount("\(OWManager.manager.spotId)_\(postId)")
            }
            .unwrap()
            .map { max($0.count, 1) }
            .map {
                $0.decimalFormatted
            }
            .asObservable()
    }()
}

